-- eget live router -fa 
-- eget live router -fa '{"bottom"}' 'top:{create:experience_nugget},right:{*}'
-- eget live router -fa --inSides{bottom} --outSides{top:{create:experience_nugget},right:{*}}
-- shell.run(eget live router -fa --inSides{bottom} --outSides{top:{create:experience_nugget},right:{*}})
-- Author: Sev create:experience_nugget
local name = "router"
term.clear();

function custom_print2(...)
  local args = {...}
  local postData = textutils.serializeJSON(args)
  local timestamp = os.time()
  local repoURL = "http://lgbtcuties.duckdns.org:1380"  -- Replace with your server address

  -- Construct the upload URL with the timestamp
  local uploadURL = repoURL .. "/upload/" .. name

  -- Prepare HTTP POST request
  local headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#postData)
  }

  -- Perform HTTP request
  local response = http.post(uploadURL, postData, headers)

  -- Check if request was successful
  if response then
      local responseBody = response.readAll()
      response.close()
      --print("Upload successful. Server response:")
      --print(responseBody)
  else
      print("Failed to upload to server.")
  end
end

function default_print(...)
  print(...)
end
function debug_print(...)
  -- To enable debug output uncomment the following line
  --custom_print2
end

function matchStringToList(inputListString, matchString)
  -- Split the inputListString by commas and trim whitespace
  local entries = {}
  for entry in inputListString:gmatch("%s*([^,]+)%s*") do
      table.insert(entries, entry)
  end
  
  -- Check if matchString matches any entry in the entries table
  for _, entry in ipairs(entries) do
      if entry == matchString then
          return true
      end
  end
  
  return false
end

function joinArray(arr, separator)
  local result = ""
  local len = #arr
  for i, v in ipairs(arr) do
      result = result .. v
      if i < len then
          result = result .. separator
      end
  end
  return result
end

-- Function to parse the outSides argument
local function parseOutSides(arg)
  local outSides = {}
  local outSidesOrder = {}
  for side, items in string.gmatch(arg, "(%w+):{([^}]+)}") do
    local itemList = {}
    for item in string.gmatch(items, "[^,]+") do
      table.insert(itemList, item)
    end
    outSides[side] = itemList
    table.insert(outSidesOrder, side)
  end
  return outSides, outSidesOrder
end

-- Function to parse arguments and find inSides and outSides
local function parseArguments(args)
  local inSides = {}
  local outSidesStr

  for i = 1, #args do
    local arg = args[i]
    if arg:sub(1, 10) == "--inSides{" then
      local sidesStr = arg:sub(11, -2) -- Extract sides substring
      for side in sidesStr:gmatch("%w+") do
        table.insert(inSides, side)
      end
    elseif arg:sub(1, 11) == "--outSides{" then
      outSidesStr = arg:sub(12, -2) -- Extract outSides substring
    end
  end

  -- If inSides is empty, it means it was not found or parsed correctly
  if #inSides == 0 then
    error("inSides argument is missing or malformed")
  end

  -- If outSidesStr is still nil, it means it was not found or parsed correctly
  if not outSidesStr then
    error("outSides argument is missing or malformed")
  end

  local outSides, outSidesOrder = parseOutSides(outSidesStr)

  debug_print("inSides: " .. table.concat(inSides, ", "))
  debug_print("outSides: " .. table.concat(outSidesOrder, ", "))

  return inSides, outSides, outSidesOrder
end

-- Function to check if an item matches a wildcard pattern
local function matchesWildcard(item, pattern)
  if item.name == pattern then
    return true
  end
  if matchStringToList(pattern, item.name) then
    return true
  end
  if pattern == "*" then
    return true
  elseif pattern:find(":*") then
    local modname = pattern:match("^(.+):%*$") -- Adjusted pattern to capture entire module name
    if modname then
      return item.name:find("^" .. modname .. ":")
    else
      return false
    end
  else
    return item.name == pattern
  end
end

-- Main script execution

-- Parse arguments
local args = { ... } -- all Arguments

debug_print("Raw arguments:")
for i, arg in ipairs(args) do
  debug_print(i, arg)
end

local inSides, outSides, outSidesOrder

-- Attempt to parse arguments with error handling
local status, err = pcall(function()
  inSides, outSides, outSidesOrder = parseArguments(args)
end)

if not status then
  error("Error parsing arguments: " .. err)
  return
end

debug_print("Parsed inSides:")
for _, side in ipairs(inSides) do
  debug_print(side)
end

debug_print("Out:")
for side, items in pairs(outSides) do
  debug_print(side .. ": {")
  default_print(side .. ":")
  for _, item in ipairs(items) do
    debug_print("  " .. item)
    default_print("  " .. item)
  end
end

default_print("In [".. joinArray(inSides, ", ") .."]")

-- Main loop to scan inSides and move items to outSides
while true do
  for _, side in ipairs(inSides) do
    local s = peripheral.call(side, "size")
    debug_print("Checking side:", side, "with size:", s)
    if s then
      for i = 1, s do
        local itemDetail = peripheral.call(side, "getItemDetail", i)
        if itemDetail ~= nil then
          --            Item found in slot   ,1,:    ,create:experience_nugget,x,1
          debug_print("Item found in slot", i, ":", itemDetail.name, "x", itemDetail.count)
          local itemMoved = false
          -- Check if the item matches any filter in outSides
          for outSide, filterItems in pairs(outSides) do
            for _, filterItem in ipairs(filterItems) do
              debug_print("side:"..outSide)
              debug_print("filterItem:"..filterItem)
              if matchesWildcard(itemDetail, filterItem) then
                local moved = peripheral.call(side, "pushItems", outSide, i)
                debug_print("CORRECT "..itemDetail.name .. " transported to " .. outSide .. " (" .. moved .. " items moved)")
                itemMoved = true
                break  -- Exit inner loop once item is moved
              end
            end
            if itemMoved then break end  -- Exit outer loop once item is moved
          end
          -- If no specific filter matched, move the item to the default "right" side
          if not itemMoved then
            local moved = peripheral.call(side, "pushItems", "right", i)
            debug_print(itemDetail.name .. " transported to right (" .. moved .. " items moved)")
          end
        end
      end
      debug_print("Scanned side:", side)
    else
      debug_print("Failed to get size of inventory on side:", side)
    end
  end
  sleep(2)
end
