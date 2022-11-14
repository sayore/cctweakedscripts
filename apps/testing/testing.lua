local json = require("/eget/libs/json")

function testing()
    local methods = peripheral.getNames()

    

    function takeOneItemFromFrontInventory()
        local front = peripheral.wrap("front")
        turtle.select(16)
        turtle.placeUp()
        repeat
            local a, b = turtle.inspectUp()
            print(a)
            os.sleep(0.8)
        until a == true
        front.pushItem("top", nil, 1, 1, 1, 1, 1)
        turtle.select(1)
        turtle.suckUp()
        turtle.select(16)
        turtle.digUp()
    end

    function placeOneItemIntoFrontInventory(mySlot)
        turtle.select(16)
        turtle.placeUp()
        repeat
            local a, b = turtle.inspectUp()
            print(a)
            os.sleep(0.8)
        until a == true
        turtle.select(mySlot)
        turtle.dropUp()
        local front = peripheral.wrap("front")
        front.pullItem("top", nil, 1, mySlot, 1, 1, 1)
        turtle.select(1)
        turtle.suckUp()
        turtle.select(16)
        turtle.digUp()
    end

    local front = peripheral.wrap("front")


    http.websocketAsync("ws://princess-sayore.ddns.net:8081")

    while true do
        local ev = { os.pullEvent() }

        if ev[1] == "websocket_message" then
            local msg = json.decode(ev[3])

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
            livews.send("{type:'console',value:'"..json.encode({ data = dump(front.items()[1]) }).."'}")
            livews.close()
        end
    end


end

function eventQueue() 
    while true do
        local ev = {os.pullEvent()}
        if ev[1]=="kill_live" then
            shell.exit()
        end
    end
end

parallel.waitForAny(testing,eventQueue)