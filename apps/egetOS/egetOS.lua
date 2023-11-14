-- imports shapedrawer.lua
local ShapeDrawer = require "/eget/libs/shapedrawer"

term.setBackgroundColor(colors.black)
term.clear();
--os.pullEvent("key")
local myDrawer = ShapeDrawer:new{}
--myDrawer:setDry()
myDrawer:drawRectangleWithText(2, 2, 25, 3, "Hello World",colors.red,colors.white,"center")
myDrawer:drawRectangleWithText(39, 2, 25, 3, "Hello World x x",colors.red,colors.white,"center")
myDrawer:drawRectangleWithText(2, 6, 25, 3, "Hello World",colors.red,colors.white,"center")

myDrawer:clear();

term.setCursorPos(1,20)

print("Is not dry.")

-- Wait for a key press
os.pullEvent("key")

term.setCursorPos(1,20)
