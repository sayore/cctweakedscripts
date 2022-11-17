--term.clear()
term.setCursorPos(1, 1)

local currentDirContent = {}
local currentDirPath = "/"
local files = fs.list("/")
for i = 1, #files do
    currentDirContent[i] = {
        name = files[i],
        type = (fs.isDir(files[i])==true and "d" or"f")
    }
end

function redraw()
    while true do
        os.sleep(1)
        term.clear()
        for key, value in ipairs(currentDirContent) do
            term.setCursorPos(2,3+key)
            term.write(key..":"..value.name.." ("..value.type..")")
        end
    end
end

function update()
    while true do
        os.sleep(1)
    end
end

function events()
    while true do

    end
end

parallel.waitForAny(redraw, update)

print("HI")
