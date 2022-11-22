--# wget run http://princess-sayore.ddns.net/eget.lua
--# wget run https://raw.githubusercontent.com/sayore/cctweakedscripts/master/eget.lua
--local repoURL = "https://raw.githubusercontent.com/sayore/cctweakedscripts/master"
local repoURL = "http://princess-sayore.ddns.net"
local wsURL =   "ws://princess-sayore.ddns.net"
local args = { ... }
if args[1] == "wget" then
    print("Active Repo: " .. repoURL)
end

term.clear()

function download(url)
    local myURL = url
    http.request(myURL)
    local event, url, handle
    repeat
        local ev = { os.pullEvent() }
        if ev[1] == "http_success" then
            url = ev[2]
            handle = ev[3]
        end
        if ev[1] == "http_failure" then
            --print("File could not be found -- exiting")
            return
        end

    until url == myURL

    return handle
end

function writeAbs(filepath, handle)
    --print("Trying to get "..filepath)
    local filedata = handle.readAll()
    handle.close()

    local file = fs.open(filepath, "w")
    file.write(filedata)
    file.close()
end

function any(array, search)
    for key, value in pairs(array) do
        if (value == search) then return true end
    end
    return false
end

local version = "0.0.11"
local outdated = false

--local versions = download(repoURL.."/version")
if fs.exists("/eget/libs/json.lua") == false then
    writeAbs("/eget/libs/json.lua", download(repoURL .. "/libs/json.lua"))
end
local json = require "/eget/libs/json"
--if version~=nil then
--local vJSON=json.decode(versions.readAll())
--if vJSON["eget"] ~= version then
--    outdated=true
--else
--    term.setTextColor(colors.lime)
--    if any(args,"-fa") == false then
--        print("eGet is on latest Version.\n [Use -fa to force an update]")
--    end
--    term.setTextColor(colors.white)
--end
--else
--    print("Could not fetch versions from repo.")
--    outdated=false
--end
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

if outdated == true or any(args, "-fa") == true or fs.exists("/eget/eget.lua") == false or
    fs.exists("/eget/libs/egetlib.lua") == false then
    --term.clear()
    if any(args, "-fa") == true then
        if outdated then
            print("Updating ..")
        else
            print("Forcing update ..")
        end
    end

    writeAbs("/eget/libs/egetlib.lua", download(repoURL .. "/libs/egetlib.lua"))
    writeAbs("/eget/libs/helper.lua", download(repoURL .. "/libs/helper.lua"))
    writeAbs("/eget/eget.lua", download(repoURL .. "/eget.lua"))
    writeAbs("/eget.lua", download(repoURL .. "/eget.lua"))

    if any(args, "-fa") == false then
        print(".. finished!")
        print("eGet v" .. version .. " alive and well!")
    else
        print("Done\n")
    end
end

local egetLib = require "/eget/libs/egetlib"

if args[1] == "help" then
    print("The following arguments can be passed")
    print("")
    print("  run -- Run a program")
    print("  list  -- List all programs")
    print("  install  -- Install a Programm")
    print("  uninstall  -- Remove a Programm")
    print("  live  -- Liverun/Restart on change")
end

if args[1] == "-i" or args[1] == "install" and args[2] == "eget" then
    local path = "/apps/" .. args[2] .. "/" .. args[2]
    writeAbs(path .. ".lua", download(repoURL .. "/" .. path .. ".lua"))
end

if args[1] == "-i" or args[1] == "install" then
    egetLib.install(repoURL, args[2])
end

if args[1] == "-r" or args[1] == "run" then
    if any(args, "-fu") then
        install(repoURL,args[2])
    end

    local path = "/apps/" .. args[2] .. "/" .. args[2]
    print("Trying to run " .. path .. ".lua\n")
    shell.run(path .. ".lua", table.concat(args, " "));
end

if args[1] == "-u" or args[1] == "uninstall" then
    local path = "/apps/" .. args[2] .. "/" .. args[2]
    fs.delete(path .. ".lua")
end

if args[1] == "-l" or args[1] == "list" then
    local path = "/apps/" .. args[2] .. "/" .. args[2]
    fs.delete(path .. ".lua")
end

local livews
if args[1] == "live" then
    local coroutine_state = "none"
    local livepath = "apps/" .. args[2] .. "/" .. args[2] .. ".lua"
    function liveRoutineUntil()
        http.websocketAsync(wsURL, { app = args[2], method = "watch" })


        while true do
            local ev = { os.pullEventRaw() }

            if ev[1] == "websocket_message" then
                local msg = json.decode(ev[3])
                if (msg["type"] == "update") then
                    term.setTextColor(colors.lime)
                    print(msg["path"] .. " changed.")
                    term.setTextColor(colors.white)
                    livews.send("got it!")
                    livews.send("exit")
                    coroutine_state = "reload"
                    return
                end
            end
            if ev[1] == "websocket_failure" then
                print(ev[3])
            end
            if ev[1] == "websocket_closed" then
                coroutine_state = "closed"
                return
            end
            if ev[1] == "websocket_success" then
                --print("Websocket Connected")
                livews = ev[3]
                livews.send("hello")
            end
            if ev[1] == "terminate" then
                print("Caught terminate event!")
                debugws.send("exit")
                --livews.close()
                coroutine_state = "exit"
                sleep(1)
                return
            end
        end

    end

    function strjoin(delimiter, list)
        local len = getn(list)
        if len == 0 then
            return ""
        end
        local string = list[1]
        for i = 2, len do
            string = string .. delimiter .. list[i]
        end
        return string
    end

    function runLive()
        local id = shell.run("/" .. livepath, table.concat(args, " "))
        --multishell.setTitle(id, "LIVE")
        --multishell.setFocus(id)
        coroutine_state = "script_exit"
    end

    if args[1] == "live" then
        while true do
            egetLib.install(repoURL, args[2])

            parallel.waitForAny(runLive, liveRoutineUntil)

            os.sleep(1)

            if coroutine_state == "script_exit" then
                term.setTextColor(colors.lime)
                print("Script exited, waiting for changes...")
                parallel.waitForAll(liveRoutineUntil)
                livews.close()
                term.setTextColor(colors.white)
            end

            if coroutine_state == "reload" then
                term.setTextColor(colors.lime)
                --shell.exit()
                print("Script changed, updating")
                term.setTextColor(colors.white)
            end

            if coroutine_state == "closed" then
                term.setTextColor(colors.red)
                print("WebSocket Closed")
                livews.close()
                livews=nil
                term.setTextColor(colors.white)
            end

            if coroutine_state == "exit" then
                return
            end

            coroutine_state = "none"
        end
    end
end
