json = require("/eget/libs/json")
local debugws
function sendDebugToWS(msg)
    http.websocketAsync("ws://princess-sayore.ddns.net", { app = "debugLib", method = "debugLog" })

    while true do
        local ev = { os.pullEvent() }

        if ev[1] == "websocket_closed" then
            coroutine_state = "closed"
            print"send succesful, returning"
            break
        end
        if ev[1] == "websocket_success" then
            --print("Websocket Connected")
            debugws = ev[3]
            debugws.send(msg)
            debugws.send("exit")
            debugws.close()
            break
            --livews.close()
        end
    end
end
--local has_block, data = turtle.inspect()
--if has_block then
  --sendDebugToWS(json.encode({type="debug",data=data}))
  -- {
  --   name = "minecraft:oak_log",
  --   state = { axis = "x" },
  --   tags = { ["minecraft:logs"] = true, ... },
  -- }
--else
--sendDebugToWS("No block in front of the turtle")
--end

return {sendDebugToWS=sendDebugToWS}