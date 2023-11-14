local EventHelper = {}
EventHelper.__index = EventHelper

function EventHelper:new()
  local self = setmetatable({}, EventHelper)
  self.events = {}
  self.lastExecutionTimes = {}
  return self
end

function EventHelper:schedule(eventName, fn, interval)
  self:clear(eventName)
  self.events[eventName] = os.startTimer(interval)
  self.lastExecutionTimes[eventName] = os.clock()
  event.listen("timer", function(_, timerId)
    if timerId == self.events[eventName] then
      fn()
      self.lastExecutionTimes[eventName] = os.clock()
      self.events[eventName] = os.startTimer(interval)
    end
  end)
end

function EventHelper:clear(eventName)
  if self.events[eventName] then
    event.ignore("timer", self.events[eventName])
    self.events[eventName] = nil
  end
end

function EventHelper:execute(eventName, timestamp)
  if not self.lastExecutionTimes[eventName] then
    self.lastExecutionTimes[eventName] = os.clock()
  end
  local interval = self.events[eventName] and self.events[eventName]._idleTimeout or 0
  local elapsedTime = timestamp - self.lastExecutionTimes[eventName]
  local numExecutions = math.floor(elapsedTime / interval)
  for i = 1, numExecutions do
    self.events[eventName]._onTimeout()
  end
end

function EventHelper:load()
  local file = fs.open("last-execution-times.json", "r")
  if file then
    self.lastExecutionTimes = textutils.unserialize(file.readAll())
    file.close()
  end
end

function EventHelper:save()
  local file = fs.open("last-execution-times.json", "w")
  file.write(textutils.serialize(self.lastExecutionTimes))
  file.close()
end

return EventHelper