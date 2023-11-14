local helper = require("/eget/libs/helper")

-- Class to draw shapes on the screen
local ShapeDrawer = {}
ShapeDrawer.__index = ShapeDrawer

function ShapeDrawer:new()
  local self = setmetatable({}, ShapeDrawer)
  self.buffer = {}
  self.bufferTextColor = {}
  self.bufferText = {}
  self.regions = {}
  self.dry=false
  return self
end

function ShapeDrawer:setDry()
  self.dry=true
end

function ShapeDrawer:setPixel(x, y, backgroundColor, textColor, letter)
  self.buffer[y] = self.buffer[y] or {}
  self.buffer[y][x] = backgroundColor
  self.bufferTextColor[y] = self.bufferTextColor[y] or {}
  self.bufferTextColor[y][x] = textColor
  self.bufferText[y] = self.bufferText[y] or {}
  self.bufferText[y][x] = letter
  if self.dry~=true then
    term.setCursorPos(x, y)
    if textColor~=nil then
      term.setTextColor(textColor)
    end
    if backgroundColor~=nil then
      term.setBackgroundColor(backgroundColor)
    end
    if letter~=nil then
      term.write(letter)
    else
      term.write(".")
    end
  end
end

function ShapeDrawer:registerRegion(x, y, width, height, fn)
  self.regions[#self.regions + 1] = {
    type = "rectangle",
    x = x,
    y = y,
    width = width,
    height = height,
    fn = fn
  }
end

function ShapeDrawer:drawRectangle(x, y, width, height, backgroundColor, textColor)
  for i = x, x + width - 1 do
    for j = y, y + height - 1 do
      self:setPixel(i, j, backgroundColor,textColor)
    end
  end
end

function ShapeDrawer:drawRectangleWithText(x, y, width, height, text, color, textcolor, alignment)
  -- Calculate the x and y coordinates for the center of the rectangle
  local centerX = x + math.floor(width / 2)
  --print(x,y,width,height,text,color,textcolor,alignment)
  local centerY = y + math.floor(height / 2)

  -- Calculate the x and y coordinates for the top left corner of the text
  local textX, textY
  if alignment == "center" then
    textX = centerX - math.floor(#text / 2)
    textY = centerY - math.floor(height / 2) + 1
  elseif alignment == "top left" then
    textX = x + 1
    textY = y + 1
  end

  -- Draw the rectangle
  for i = x, x + width - 1 do
    for j = y, y + height - 1 do
      self:setPixel(i, j, color)
    end
  end
  self:writeWrappedText(textX, textY, width, text, textcolor)
end

function ShapeDrawer:writeText(x, y, text, color)
  for i = 1, #text do
    self:setPixel(x + i - 1, y, text:sub(i, i))
  end
end

function ShapeDrawer:writeWrappedText(x, y, width, text, color)
  local words = helper.explode(" ",text)
  local line = ""
  for i, word in ipairs(words) do
    -- If the line is too long to fit within the bounds, go to the next line
    if #line + #word > width then
      y = y + 1
      line = ""
    end
    -- Add the word to the current line
    line = line .. word .. " "
  end
  
  -- Write the text at the specified coordinates
  for i = 1, #line do
    self:setPixel(x + i - 1, y, nil, color, line:sub(i, i))
  end
  
end

function ShapeDrawer:registerCircleRegion(x, y, radius, fn)
  self.regions[#self.regions + 1] = {
    type = "circle",
    x = x,
    y = y,
    radius = radius,
    fn = fn
  }
end

function ShapeDrawer:registerTriangleRegion(x1, y1, x2, y2, x3, y3, fn)
  self.regions[#self.regions + 1] = {
    type = "triangle",
    x1 = x1,
    y1 = y1,
    x2 = x2,
    y2 = y2,
    x3 = x3,
    y3 = y3,
    fn = fn
  }
end

function ShapeDrawer:handleTouchEvent(event, side, x, y)
  for _, region in ipairs(self.regions) do
    if region.type == "rectangle" then
      if x >= region.x and x < region.x + region.width and y >= region.y and y < region.y + region.height then
        region.fn(event, side, x, y)
        return true
      end
    elseif region.type == "circle" then
      local dx = x - region.x
      local dy = y - region.y
      if dx * dx + dy * dy <= region.radius * region.radius then
        region.fn(event, side, x, y)
        return true
      end
    end
  end
end

function ShapeDrawer:drawLine(x1, y1, x2, y2, color)
  if x1 == x2 then
    -- Vertical line
    for y = y1, y2 do
      self:setPixel(x1, y, color)
    end
  elseif y1 == y2 then
    -- Horizontal line
    for x = x1, x2 do
      self:setPixel(x, y1, color)
    end
  else
    -- Diagonal line
    local slope = (y2 - y1) / (x2 - x1)
    local yIntercept = y1 - slope * x1
    for x = x1, x2 do
      local y = slope * x + yIntercept
      self:setPixel(x, y, color)
    end
  end
end

function ShapeDrawer:drawCircle(x, y, radius, color)
  for i = -radius, radius do
    for j = -radius, radius do
      if i * i + j * j <= radius * radius then
        self:setPixel(x + i, y + j, color)
      end
    end
  end
end

function ShapeDrawer:drawTriangle(x1, y1, x2, y2, x3, y3, color)
  self:drawLine(x1, y1, x2, y2, color)
  self:drawLine(x2, y2, x3, y3, color)
  self:drawLine(x3, y3, x1, y1, color)
end

function ShapeDrawer:clear()
  if dry~=true then
    for y, row in pairs(self.buffer) do
      for x, color in pairs(row) do
        term.setCursorPos(x, y)
        term.setBackgroundColor(color)
        term.setTextColor(bufferTextColor[x][y])
        term.write(bufferText[x][y])
      end
    end
  end
  self.buffer = {}
end

return ShapeDrawer