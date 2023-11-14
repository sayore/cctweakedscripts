--# wget run http://cozycatcrew.de:1380/install.lua
--# wget run http://princess-sayore.ddns.net/install.lua
--# wget run https://raw.githubusercontent.com/sayore/cctweakedscripts/master/eget.lua
--local repoURL = "https://raw.githubusercontent.com/sayore/cctweakedscripts/master"
json = require("/eget/libs/json")
install = require("/eget/libs/installLib").install
writeAbs = require("/eget/libs/helper").writeAbs
download = require("/eget/libs/helper").download

local repoURL = "http://cozycatcrew.de:1380"
local wsURL =   "ws://cozycatcrew.de:1380"
local args = { ... }
term.clear()

shell.run("wget run http://cozycatcrew.de:1380/install.lua")

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
    install(repoURL, args[2])
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
local socketOpen=false;
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
                socketOpen=false;
                return
            end
            if ev[1] == "websocket_success" then
                --print("Websocket Connected")
                livews = ev[3]
                socketOpen=true;
            end
            if ev[1] == "terminate" then
                print("Caught terminate event!")
                livews.send("exit")
                --livews.close()
                socketOpen=false;
                coroutine_state = "exit"
                sleep(1)
                return
            end
        end

    end

    

    function runLive()
        local id = shell.run("/" .. livepath, table.concat(args, " "))
        --multishell.setTitle(id, "LIVE")
        --multishell.setFocus(id)
        coroutine_state = "script_exit"
    end

    if args[1] == "live" then
        while true do
            install(repoURL, args[2])

            parallel.waitForAny(runLive, liveRoutineUntil)

            -- WebSocket is closed here because the function above died
            -- That means the script was either updated or exited
            -- We can assume that the socket is closed at this point
            if socketOpen==true then
                socketOpen=false;
            end

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
