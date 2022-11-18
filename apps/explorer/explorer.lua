local touchscreenLib = require "/apps/touchscreenLib/touchscreenLib"
local touchscreen = touchscreenLib.touchscreen

--term.clear()
term.setCursorPos(1, 1)
term.write("Trying to run!")

local currentDirContent = {}
local currentDirPath = "/"
local files = fs.list(currentDirPath)
function changeDir(newAppendToCombine)
    currentDirContent = {}
    currentDirPath = fs.combine(currentDirPath, newAppendToCombine)
    files = fs.list(currentDirPath)
    for i = 1, #files do
        currentDirContent[i] = {
            name = files[i],
            type = (fs.isDir(files[i]) == true and "d" or "f")
        }
    end
    if redraw ~= nil then
        redraw()
    end
end

changeDir(".")

local active = ""
local state = touchscreen.writeAt(1, 1, "State ~ ")
local goBackLink = touchscreen.writeAt(1, 3, "<< [ /.. ]",function() 
    changeDir("..")
end)
function redraw()
    --touchscreen.update(state,"Clicked ")
    for key, value in ipairs(currentDirContent) do
        touchscreen.writeAt(2, 3 + key, ((value.name==active) and "&4" or "&3")..key .. ":" .. value.name .. " (" .. value.type .. ")&1", function()
            touchscreen.update(state, "Actions  on " .. value.name .." ("..(value.type=="d" and "directory" or "file")..")")
            active=value.name
            if value.type=="f" then
                drawActions(1, 2, {
                    {
                        text = " &3[Run]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Run]")
                            shell.openTab(value.name)
                        end
                    },
                    {
                        text = "&3[Edit]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Edit]")
                            shell.openTab("edit "..value.name)
                        end
                    },
                    {
                        text = "&3[Copy]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Copy]")
                        end
                    },
                    {
                        text = "&3[Cut]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Cut]")
                        end
                    },
                    {
                        text = "&3[Delete]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Delete]")
                        end
                    }
                })
            end
            if value.type=="d" then
                drawActions(1, 2, {
                    {
                        text = " &3[Open]&1",
                        action = function()
                            changeDir("./"..value.name)
                        end
                    },
                    {
                        text = "&3[Copy]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Copy]")
                        end
                    },
                    {
                        text = "&3[Cut]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Cut]")
                        end
                    },
                    {
                        text = "&3[Delete]&1",
                        action = function()
                            touchscreen.update(state, "Action " .. value.name .. "[Delete]")
                        end
                    }
                })
            end
        end, { temp = 1 })
    end
    term.clear()
    touchscreen.draw()
end

local actionPointer = {}
function drawActions(x, y, actions)
    for key, value in pairs(actionPointer) do
        touchscreen.delete(value)
    end
    actionPointer={}
    local offset = 0
    for key, value in pairs(actions) do
        table.insert(
            actionPointer,
            0,
            touchscreen.writeAt(
                x + offset, 
                y, 
                value.text, 
                value.action))
        offset = offset + string.len(value.text) -3
    end
end

function loopyfyDraw()
    while true do
        os.sleep(1)
        redraw()
    end
end

function update()
    while true do
        os.sleep(5)
    end
end

function events()
    while true do
        local ev = { os.pullEvent() }
        --touchscreen.update(state,"Clicked ".."Event " ..ev[1])
        if ev[1] == "mouse_click" then
            touchscreen.clickAt(ev[3], ev[4])
            --touchscreen.update(state,"[ev]Clicked "..ev[3].." "..ev[4])
            redraw()
        end
    end
end

parallel.waitForAny(loopyfyDraw, update, events)

print("HI")
