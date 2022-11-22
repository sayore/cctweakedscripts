local args = { ... }

for key, value in pairs(args) do
    print(key.." : "..value)
end

function waitFor(fn)
    while fn()~=true do
        os.sleep(0.1)
    end
end

function selectAnySlotWithItem() 
    for i = 1, 16 do
        turtle.select(i)
        term.write("["..i.." - "..turtle.getItemCount().."]..")
        if turtle.getItemCount()>=1 then
            print("Selected "..i)
            return 
        end
    end
end

if args[3] == "bridge" then
    local width = args[4]
    local depthReached=1

    print("Width: "..width)
    while turtle.getItemCount()~=0 do
        turtle.refuel()
    end

    while true do
        print("Selecting new Slot..")
        selectAnySlotWithItem() 
        print("Alr")
        waitFor(turtle.placeDown)
        print("Turn")
        waitFor(turtle.turnRight)
        
        for i = 1, width do
            selectAnySlotWithItem() 
            waitFor(turtle.forward)
            waitFor(turtle.placeDown)
        end

        waitFor(turtle.turnLeft)
        waitFor(turtle.forward)
        waitFor(turtle.turnLeft)

        for i = 1, width do
            waitFor(turtle.forward)
            selectAnySlotWithItem() 
            waitFor(turtle.placeDown)
        end

        waitFor(turtle.turnRight)
        waitFor(turtle.forward)
    end
end

