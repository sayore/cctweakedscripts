-- Function to display serialized JSON
local function displayJSON(input)
  -- Serialize the input to JSON
  local json = textutils.serialize(input)

  -- Print the JSON in a formatted way
  local indentLevel = 0
  local inString = false
  local function printWithFormat(...)
    local s = "&1"
    for k, v in ipairs(arg) do
      s = s .. v
    end
    s = s .. "&0"

    local fields = {}
    local lastcolor, lastpos = "0", 0
    for pos, clr in s:gmatch "()&(%x)" do
      table.insert(fields, { s:sub(lastpos + 2, pos - 1), lastcolor })
      lastcolor, lastpos = clr, pos
    end

    for i = 2, #fields do
      term.setTextColor(2 ^ (tonumber(fields[i][2], 16)))
      io.write(fields[i][1])
    end
  end
  for i = 1, #json do
    local c = json:sub(i, i)
    if c == "{" or c == "[" then
      printWithFormat(c, "&2")
      indentLevel = indentLevel + 1
    elseif c == "}" or c == "]" then
      indentLevel = indentLevel - 1
      printWithFormat(string.rep("  ", indentLevel) .. c, "&2")
    elseif c == "," then
      printWithFormat(c .. string.rep("  ", indentLevel), "&2")
    elseif c == ":" then
      printWithFormat(c .. " ", "&2")
    elseif c == "\"" then
      inString = not inString
      printWithFormat(c, "&3")
    else
      printWithFormat(c)
    end
  end
  term.setTextColor(colors.white)
end

-- Example usage
local exampleTable = {
  foo = "bar",
  baz = {
    qux = 123
  }
}
displayJSON(exampleTable)
