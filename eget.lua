--# wget run http://princess-sayore.ddns.net/eget.lua
--# wget run https://raw.githubusercontent.com/sayore/cctweakedscripts/master/eget.lua
local args = {...}
local repoURL = "https://raw.githubusercontent.com/sayore/cctweakedscripts/master"

function download(url) 
    print("Downloading.. \n"..url)
    local myURL = url
    http.request(myURL)
    local event, url, handle
    repeat
        local ev = {os.pullEvent()}
        if ev[1]=="http_success" then
            url = ev[2]
            handle = ev[3]
        end
        if ev[1] == "http_failure" then
            print("File could not be found -- exiting")
            return
        end

    until url == myURL

    return handle
end

function writeAbs(filepath, handle)
    print("Trying to get "..filepath)
    local filedata = handle.readAll()
    handle.close()

    local file = fs.open(filepath, "w")
    file.write(filedata)
    file.close()
end

function any(array, value)
    for key, value in pairs(array) do
        if(value==value) then return true end
    end
    return false
end

local version = "0.0.11"
local outdated = false

local versions = download(repoURL.."/versions")
if fs.exists("/eget/libs/json.lua") == false then
    writeAbs("/eget/libs/json.lua",     download(repoURL.."/libs/json.lua"))
end
local json = require "/eget/libs/json"
if versions~=nil then 
local vJSON=json.decode(versions.readAll())
if vJSON["eget"] ~= version then
    outdated=true
else
    term.setTextColor(colors.lime)
    print("eGet is on latest Version. [Use -fa to force an update]")
    parallel.waitForAll(liveRoutineUntil)
    term.setTextColor(colors.white)
end
else
    print("Could not fetch versions from repo.")
    outdated=false
end

if outdated or any(args,"-fa") or fs.exists("/eget/eget.lua") == false or fs.exists("/eget/libs/eget.lib.lua") == false then
    --term.clear()
    if any(args,"-fa") == false then
        if outdated then
            print("EGET Outdated! Updating..")
        else
            print("EGET will be installed..")
        end
    end

    writeAbs("/eget/libs/eget.lib.lua", download(repoURL.."/libs/eget.lib.lua"))
    writeAbs("/eget/eget.lua",          download(repoURL.."/eget.lua"))
    writeAbs("/eget.lua",               download(repoURL.."/eget.lua"))

    if any(args,"-fa") == false then
        print(".. finished!")
        print("eGet v"..version.." alive and well!")
    else
        print("(silent update)")
    end
end

local egetLib = require "/eget/libs/eget.lib.lua"

if args[1] =="help" then
    print("The following arguments can be passed")
    print("")
    print("  run -- Run a program")
    print("  list  -- List all programs")
    print("  install  -- Install a Programm")
    print("  uninstall  -- Remove a Programm")
    print("  live  -- Liverun/Restart on change")
end

if args[1] =="-i" or args[1]=="install" and args[2]=="eget" then
    local path = "/apps/"..args[2].."/"..args[2]
    writeAbs(path..".lua",               download(repoURL.."/"..path..".lua"))
end

if args[1] =="-i" or args[1]=="install" then
    egetLib.install(repoURL,args[2])
end

if args[1] =="-r" or args[1]=="remove"  then
    local path = "/apps/"..args[2].."/"..args[2]
    print("Trying to run "..path..".lua")
    os.run({},path..".lua");
end

if args[1] =="-u" or args[1]=="uninstall"  then
    local path = "/apps/"..args[2].."/"..args[2]
    fs.delete(path..".lua")
end

if args[1] =="-l" or args[1]=="list"  then
    local path = "/apps/"..args[2].."/"..args[2]
    fs.delete(path..".lua")
end

if args[1]=="live" then
    local coroutine_state = "none"
    local livepath = "apps/"..args[2].."/"..args[2]..".lua"
    local livews
    function liveRoutineUntil()
        http.websocketAsync("ws://princess-sayore.ddns.net:8081")

        while true do
            local ev = {os.pullEvent()}

            if ev[1]=="websocket_message" then
                local msg = json.decode(ev[3])
                if(msg["type"]=="update") then
                    term.setTextColor(colors.lime)
                    print(msg["path"].." changed.")
                    term.setTextColor(colors.white)
                    livews.send("got it!")
                    livews.close()
                    coroutine_state="reload"
                    return
                end
            end
            if ev[1]=="websocket_failure" then
                print(ev[3])
            end
            if ev[1]=="websocket_closed" then
                coroutine_state="closed"
                return
            end
            if ev[1]=="websocket_success" then
                --print("Websocket Connected")
                livews = ev[3]
                livews.send("hello")
            end
        end
    end


    function runLive()
        local r = require "cc.require"
        print("require")
        print(require)

        local id = shell.run("/"..livepath)
        --multishell.setTitle(id, "LIVE")
        --multishell.setFocus(id)
        coroutine_state ="script_exit"
    end

    if args[1] =="live" or args[1]=="live" then
        while true do
            writeAbs("/"..livepath, download("http://princess-sayore.ddns.net/"..livepath))

            os.queueEvent("kill_live")
            parallel.waitForAny(runLive, liveRoutineUntil)
            
            if coroutine_state=="script_exit" then
                term.setTextColor(colors.lime)
                print("Script exited, waiting for changes...")
                parallel.waitForAll(liveRoutineUntil)
                term.setTextColor(colors.white)
            end

            if coroutine_state=="reload" then
                term.setTextColor(colors.lime)
                shell.exit()
                print("Script changed, updating")
                
                term.setTextColor(colors.white)
            end

            if coroutine_state=="closed" then
                term.setTextColor(colors.red)
                print("Websocket Closed? Exiting")
                term.setTextColor(colors.white)
                return
            end
            
            coroutine_state="none"
        end
    end
end