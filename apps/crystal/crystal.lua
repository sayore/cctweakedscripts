local debug = require "/apps/debugLib/debugLib"
local has_block, data = turtle.inspect()
debug.sendDebugToWS("{type:'debug',msg:'CRYSTAL'}")
while true do
    has_block, data = turtle.inspectUp()
    if data['name'] == "ae2:quartz_cluster" then
        turtle.digUp()
    end 
    
    has_block, data = turtle.inspect()
    if data['name'] == "ae2:quartz_cluster" then
        turtle.dig()
    end 
    if data['name'] == "ae2:quartz_block" then
        turtle.dig()
        turtle.select(16)
        turtle.place()
    end 
    if data['name'] == "minecraft:air" or data['name'] == nil then
        turtle.select(16)
        turtle.place()
    end 

    has_block, data = turtle.inspectDown()
    if data['name'] == "ae2:quartz_cluster" then
        turtle.digDown()
    end 
    os.sleep(2)
    turtle.turnRight()
end