local touchscreen = {
    screendata={},
    debug
}
local handlerIdAI=1

function printWithFormat(...)
    local s = "&1"
    for k, v in ipairs(arg) do
        s = s .. v
    end
    s = s .. "&0"

    local fields = {}
    local lastcolor, lastpos = "0", 0
    for pos, clr in s:gmatch "()&(%x)" do
        table.insert(fields, { s:sub(lastpos + 2, pos - 1), lastcolor })
        lastcolor, lastpos = clr, pos
    end

    for i = 2, #fields do
        term.setTextColor(2 ^ (tonumber(fields[i][2], 16)))
        io.write(fields[i][1])
    end
end

function checkCollision(x,y)
    --touchscreen.update(touchscreen.debug,((y==value.y) and "Y is same" or "Yis not same")..((x>=value.x) and "X is greater" or "X is smaller")..((x<(value.x+value.l)) and "X is greater" or "X is  smaller"))
    for key, value in pairs(touchscreen.screendata) do
        if value.action ~= nil then 
            if y==value.y then
                if x>=value.x and x<(value.x+value.l) then
                    touchscreen.update(touchscreen.debug,"Action found and executed")
                    return value.action()
                end
            end
        end
    end
    return nil
end

local clicked=""
touchscreen.clickAt = function (x,y)
    clicked = x.." "..y
    --touchscreen.update(touchscreen.debug,"=_=")
    return checkCollision(x,y)
end

touchscreen.writeAt = function(x,y,text,action,extra)
    if handlerIdAI == nil then handlerIdAI=1 end
    handlerIdAI=handlerIdAI+1
    touchscreen.screendata[handlerIdAI] = {
        x=x,
        y=y,
        l=string.len(text),
        text=text,
        action=action,
        extra=extra
    }
    --term.write(handlerIdAI)
    return handlerIdAI
end

touchscreen.move = function(handler, x, y)
    if touchscreen.screendata[handler] ~=nil then
        if x~=nil then
            touchscreen.screendata[handler].x = x
        end
        if y~=nil then
            touchscreen.screendata[handler].y = y
        end
    end
end

touchscreen.delete = function(handler)
    if touchscreen.screendata[handler]~=nil then
        touchscreen.screendata[handler] = nil
    end
end

touchscreen.update = function(handlerId,text,action)
    --term.write(handlerId)
    if touchscreen.screendata[handlerId] ~=nil then
        if text~=nil then
            touchscreen.screendata[handlerId].text = text
        end
        if action~=nil then
            touchscreen.screendata[handlerId].text = action
        end
    end
end

touchscreen.draw = function()
    for key, value in pairs(touchscreen.screendata) do
        if value~=nil then
            term.setCursorPos(value.x,value.y)
            printWithFormat(value.text)
            if value.extra ~=nil and value.extra.temp~=nil then
                if(value.extra.temp<=0) then
                    touchscreen.screendata[key] = nil
                else
                    value.extra.temp=value.extra.temp-1
                end
            end
        end 
    end
end

touchscreen.reset = function()
    touchscreen.screendata = {}
end

touchscreen.debug = touchscreen.writeAt(2,10,"Debug ")

return { touchscreen = touchscreen }