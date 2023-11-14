-- Class to draw shapes on the screen
local ShapeDrawer = {}
ShapeDrawer.__index = ShapeDrawer

function ShapeDrawer:new()
  local self = setmetatable({}, ShapeDrawer)
  self.buffer = {}
  self.regions = {}
  return self
end

function ShapeDrawer:setPixel(x, y, color)
  self.buffer[y] = self.buffer[y] or {}
  self.buffer[y][x] = color
  term.setCursorPos(x, y)
  term.setBackgroundColor(color)
  term.write(" ")
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

function ShapeDrawer:drawRectangle(x, y, width, height, color)
  for i = x, x + width - 1 do
    for j = y, y + height - 1 do
      self:setPixel(i, j, color)
    end
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
  for y, row in pairs(self.buffer) do
    for x, color in pairs(row) do
      term.setCursorPos(x, y)
      term.setBackgroundColor(color)
      term.write(" ")
    end
  end
  self.buffer = {}
end

return ShapeDrawer