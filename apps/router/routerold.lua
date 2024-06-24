














local s = peripheral.call("bottom","size")
print(s)

while true do
  for i = 1, s do
    if peripheral.call("bottom","getItemDetail",i) ~=nil then
      if peripheral.call("bottom","getItemDetail",i).count > 1 and peripheral.call("bottom","getItemDetail",i).name == "create:experience_nugget" then
        peripheral.call("bottom","pushItems","top",i)
        print("ex orbs transported")
      elseif peripheral.call("bottom","getItemDetail",i).count > 1 and peripheral.call("bottom","getItemDetail",i).name ~= "create:experience_nugget" then
        peripheral.call("bottom","pushItems","right",i)
        print("trash transported")
      end
    end
    print("looped")
    
  end
  sleep(2)
end


local args = { ... } -- all Arguments
-- in Sides will be any sides given as the first argument formattet as {"top","bottom","left","right","front","back"} which can contain any combination of these and all of them will be scanned trough

-- out Sides will be fromattet as top:{minecraft:torch,minecraft:stone} bottom:{minecraft:stone} left:{minecraft:stone} right:{minecraft:stone} front:{minecraft:stone} back:{minecraft:stone}

-- We will scan trough all inSides' inventories and look for items that match the outSides filter we gave
-- Use the given code ass reference
-- You can get the args with args = { ... }

-- Check if any arguments were given
if #args > 0 then
    -- Set the inSides variable to the first argument
    inSides = args[1]
    -- Check if the first argument is a table
    if type(inSides) == "table" then
        -- Iterate over each item in the inSides table and check if it is a string
        for i, side in ipairs(inSides) do
            if type(side) ~= "string" then
                print("Error: Argument " .. i .. " in inSides is not a string")
                return
            end
        end
    else
        print("Error: inSides is not a table")
        return
    end
else
    -- If no arguments were given, set inSides to all sides
    inSides = {"top", "bottom", "left", "right", "front", "back"}
end

-- Initialize the outSides variable as an empty table
outSides = {}

-- Iterate over each side in inSides
for _, side in ipairs(inSides) do
    -- Check if the side exists on the bottom peripheral
    if peripheral.isPresent(side .. "Side") then
        -- Get the inventory of the side
        local inventory = peripheral.call(side .. "Side", "getInventory")
        -- Check if the inventory is a table
        if type(inventory) == "table" then
            -- Iterate over each item in the inventory
            for i, item in ipairs(inventory) do
                -- Check if the item is a table
                if type(item) == "table" then
                    -- Check if the outSides table does not contain the current side
                    if not outSides[side] then
                        -- Initialize the side in outSides as an empty table
                        outSides[side] = {}
                    end
                    -- Add the item to the outSides table for the current side
                    table.insert(outSides[side], item)
                else
                    print("Error: Item " .. i .. " in " .. side .. " side inventory is not a table")
                end
            end
        else
            print("Error: " .. side .. " side inventory is not a table")
        end
    else
        print("Error: " .. side .. " side peripheral is not present")
    end
end
