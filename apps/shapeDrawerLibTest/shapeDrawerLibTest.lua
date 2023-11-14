-- Load the ShapeDrawer class
local ShapeDrawer = require "/apps/shapeDrawerLib/shapeDrawerLib"

term.clear()

-- Create a new ShapeDrawer object
local shapeDrawer = ShapeDrawer:new()

-- Register a rectangle region and a function to be called when the region is touched
shapeDrawer:registerRegion(2,2,4,4, function(event, side, x, y)
  print("Rectangle region touched!")
end)

-- Register a circle region and a function to be called when the region is touched
shapeDrawer:registerCircleRegion(15, 5, 5, function(event, side, x, y)
  print("Circle region touched!")
end)

-- Register a triangle region and a function to be called when the region is touched
shapeDrawer:registerTriangleRegion(45, 1, 50, 10, 55, 1, function(event, side, x, y)
  print("Triangle region touched!")
end)

-- Draw some shapes

--TransFlag  lol
--shapeDrawer:drawRectangle(1, 1, 100, 5, colors.lightBlue)
--shapeDrawer:drawRectangle(1, 5, 100, 4, colors.magenta)
--shapeDrawer:drawRectangle(1, 9, 100, 4, colors.white)
--shapeDrawer:drawRectangle(1,9+4, 100, 4, colors.magenta)
--shapeDrawer:drawRectangle(1, 9+4+4, 100, 4, colors.lightBlue)

--shapeDrawer:drawLine(15, 1, 25, 10, colors.green)
shapeDrawer:drawTriangle(45, 1, 50, 10, 55, 1, colors.red)
shapeDrawer:drawRectangle(2, 2, 4, 4, colors.black)

-- Clear the screen and redraw the shapes

-- Handle touch events
while true do
  local event, side, x, y = os.pullEvent("mouse_click")
  local res = shapeDrawer:handleTouchEvent(event, side, x, y)
  if res then
    print("Region touched")
  else
    print("No region touched.")
  end
end
