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
    print("Refuel..")
    turtle.select(1)
    while turtle.getItemCount()~=0 do
        turtle.refuel()
    end
    print("Refueled..")
    while true do
        print("Selecting new Slot..")
        selectAnySlotWithItem() 
        print("Alr")
        turtle.placeDown()
        turtle.forward()
        turtle.dig()
        turtle.digUp()
    end
end

