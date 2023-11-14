-- This is a paint program with a "fill bucket" menu at the bottom of the screen

-- Load the paintutils module


-- Set the size of the canvas
local width = 50
local height = 20

-- Create the canvas
local canvas = {}
for y = 1, height do
  canvas[y] = {}
  for x = 1, width do
    canvas[y][x] = colors.white
  end
end

-- Set the pen color to black
local penColor = colors.black

-- Set the fill bucket color to white
local fillColor = colors.white

-- Set the menu height
local menuHeight = 3

-- Draw the canvas and menu
local function draw()
  term.clear()
  term.setCursorPos(1, 1)
  paintutils.drawImage(canvas, 1, 1)
  term.setCursorPos(1, height + 1)
  print("Paint Menu")
  print("-----------")
  print("1. Pen color: " .. penColor)
  print("2. Fill bucket color: " .. fillColor)
  print("3. Clear canvas")
  print("4. Exit")
end

-- Handle menu input
local function handleMenuInput(input)
  if input == "1" then
    penColor = read("Enter new pen color: ")
  elseif input == "2" then
    fillColor = read("Enter new fill bucket color: ")
  elseif input == "3" then
    for y = 1, height do
      for x = 1, width do
        canvas[y][x] = colors.white
      end
    end
  elseif input == "4" then
    return false
  end
  return true
end

-- Main loop
while true do
  draw()
  local event, side, x, y = os.pullEvent("monitor_touch")
  if y > height then
    -- Handle menu input
    local input = string.sub(side, -1)
    if not handleMenuInput(input) then
      break
    end
  else
    -- Draw on the canvas
    canvas[y][x] = penColor
  end
end
