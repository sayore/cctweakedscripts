local debugws
function sendDebugToWS(msg)
    http.websocketAsync("ws://princess-sayore.ddns.net", { app = "debugLib", method = "debugLog" })

    while true do
        local ev = { os.pullEventRaw() }

        if ev[1] == "websocket_closed" then
            coroutine_state = "closed"
            print"send succesful, returning"
            return
        end
        if ev[1] == "websocket_success" then
            --print("Websocket Connected")
            debugws = ev[3]
            debugws.send(msg)
            debugws.send("exit")
            --livews.close()
        end
        if ev[1] == "terminate" then
            print("Caught terminate event!")
            debugws.send("exit")
            pcall(debugws and debugws.close or function()end)
            coroutine_state="exit"
            sleep(1)
        end
    end
end
sendDebugToWS("Debug Test!")