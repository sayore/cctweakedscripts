function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local posCube = vec(0,0,0)
events.ENTITY_INIT:register(function()
    nameplate.LIST:setText('{"translate": "%s ", "with": [{"font":"figura:default", "text":"ᚸ"}], "color": "reset", "extra": [{"text": "Sayo", "color": "white"}]}')
    nameplate.CHAT:setText('{"translate": "%s ", "with": [{"font":"figura:default", "text":"ᚸ"}], "color": "reset", "extra": [{"text": "Sayo", "color": "white"}]}')
    nameplate.ENTITY:setText('{"translate": "%s ", "with": [{"font":"figura:default", "text":"ᚸ"}], "color": "reset", "extra": [{"text": "Sayo", "color": "white"}]}')

    vanilla_model.ALL:setVisible(false)

    --models.sev.setPrimaryRenderType("World")

    --log(dump(animations))
    --logTable(vanilla_model)
    log("loaded! ?")
    if player ~= nil then
      posCube = player:getPos()
    end


    animations.sev["testAnim"]:play()

end)

local count = 0

events.POST_WORLD_RENDER:register(function()
   if player ~= nil then
      posCube = posCube * vec(0.99,0.99,0.99) + player:getPos() * vec(0.01,0.01,0.01)

      models.sev.World.rotator:setPos(posCube*16) --<<<<<<<
      count=count+1;
      if count %30 == 1 then
         --log(posCube)
       end
   end
  
end) 