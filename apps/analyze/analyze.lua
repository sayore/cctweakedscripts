local args = { ... }

--print(textutils.serialize(args))
-- View 0 = Lists all peripherals
-- View 1 = Shows a peripherals methods
local view = 0
local selection = 0

function getArgs(func)
  local args = {}
  for i = 1, debug.getinfo(func).nparams, 1 do
      table.insert(args, debug.getlocal(func, i));
  end
  return args;
end

function draw()
  term.clear()
  term.setCursorPos(1, 1)
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  print("Analyzer - PERIPHERAL METHOD VIEWER\n  Press up and down to select a peripheral\n")
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  for index, value in ipairs(peripheral.getNames()) do
    term.setBackgroundColor(colors.red)
    print(value .. "(" .. peripheral.getType(value) .. ")")
    term.setBackgroundColor(colors.black)

    if index == selection then
      term.setBackgroundColor(colors.blue)
      for index, method in ipairs(peripheral.getMethods(value)) do
        print("|   " .. method .. "( .. )")
      end
    end
    term.setBackgroundColor(colors.black)
  end
end

draw()
while true do
  local key = ""
  local eventData = {os.pullEvent()}
  key = eventData[2]
  if key == keys.up then
    selection = selection - 1
  elseif key == keys.down then
    selection = selection + 1
  elseif key == keys.enter then
    if view == 0 then
      view = 1
    elseif view == 1 then
      view = 0
    end
  end
  if selection < 0 then
    selection = 0
  end
  if selection > #peripheral.getNames() then
    selection = #peripheral.getNames()
  end
  if(eventData[1] == "key") then
    draw()
  end
  if(eventData[1] == "peripheral") then
    draw()
  end
  if(eventData[1] == "peripheral_detach") then
    draw()
  end
end
