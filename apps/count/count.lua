-- eget live count --from=back --to=front
local helper = require "/apps/helperLib/helperLib"
local args = { ... }
local fromSide = "back"
local toSide = "right"

function startsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

for index, value in ipairs(args) do
    --print(value)
    if startsWith(value, "--from=") == true then
        fromSide = string.sub(value, string.len("--from= "))
    end
    if startsWith(value, "--to=") == true then
        toSide = string.sub(value, string.len("--to= "))
    end
end

print("FROM " .. fromSide .. " TO " .. toSide)

local from = peripheral.wrap(fromSide)
local to = peripheral.wrap(toSide)
local monitor = peripheral.wrap("top")
print("Terminal Redirect!")
term.redirect(monitor)
print("Terminal Redirect! 2")
monitor.clear()
monitor.setTextScale(0.5)
monitor.write("HELLO")
local movedTable = {}
local movedSinceStartTable = {}
local movedTableLastUpdate = {}
print("Start Cycle") --eget live count -fa
if fs.exists("state.count.db") then
    local file = fs.open("state.count.db", "r")
    movedTable = textutils.unserialize(file.readAll())
    --movedTableLastUpdate = textutils.unserialize(file.readAll())
    file.close()
end




function padLeft(str, len, char)
    return string.rep(char, len - string.len(str)) .. str
end

function padRight(str, len, char)
    return str .. string.rep(char, len - string.len(str))
end

local specialItems = {}
specialItems["Lead Ore"] = "&b"
specialItems["Ancient Debris"] = "&1"
specialItems["Diamond Ore"] = "&3"
specialItems["Emerald Ore"] = "&5"
specialItems["Gold Ore"] = "&4"
specialItems["Iron Ore"] = "&8"
specialItems["Glowstone"] = "&4"
specialItems["Nikolite Ore"] = "&9"

local specialWords = {}
specialWords["Lead"] = "&b"
specialWords["Nether"] = "&1"
specialWords["Diamond"] = "&3"
specialWords["Emerald"] = "&5"
specialWords["Copper"] = "&1"
specialWords["Bronze"] = "&1"
specialWords["Gold"] = "&4"
specialWords["Iron"] = "&8"
specialWords["Steel"] = "&8"
specialWords["Aluminum"] = "&0"
specialWords["Glowstone"] = "&4"
specialWords["Invar"] = "&5"
specialWords["Nikolite"] = "&9"

function printWithFormat(...)
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

function printlnWithFormat(...)
    printWithFormat(...)
    print(" ")
end


function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

local max_ln = 24
local start = os.clock()
local updateCycle = 0
while true do
    local now = os.clock()
    table.sort(movedTable);
    for i = 1, from.size() do
        local itemdetail = from.getItemDetail(i)
        if itemdetail ~= nil then
            local pushed = from.pushItems(toSide, i, 64)
            local itemName=itemdetail["displayName"]
            helper.tableAddToValue(movedTable,itemName, pushed)
            helper.tableAddToValue(movedSinceStartTable,itemName, pushed)
            helper.tableAddToValue(movedTableLastUpdate,itemName, pushed)
        end
    end
    sleep(0.1)
    term.clear()
    monitor.setCursorPos(1, 1)
    print("Watching Items ")

    
    local entry = 0
    for itemName, amountMovedEver in pairsByKeys(movedTable) do
        local perSecond = 0
        local perSecondSinceStart = 0
        if movedSinceStartTable[itemName]~=nil then
            perSecondSinceStart = movedSinceStartTable[itemName] / (now - start)
        end
        local moreThanBefore = ""
        local moreThanAtStart = ""
        if movedTableLastUpdate[itemName] ~= nil and movedTableLastUpdate[itemName] ~= 0 then
            moreThanBefore = " (+ " .. movedTableLastUpdate[itemName] .. " Pcs)"
        end
        if movedSinceStartTable[itemName] ~= nil and movedSinceStartTable[itemName] ~= 0 then
            moreThanBefore = " (+ " .. movedSinceStartTable[itemName] .. " Pcs)"
        end
        movedTableLastUpdate[itemName] = 0
        local isSpecial = "&7"
        for k2, v2 in pairs(specialWords) do
            if string.find(itemName, k2) then
                isSpecial = v2
            end
        end
        if specialItems[itemName] ~= nil then
            isSpecial = specialItems[itemName]
        end
        printWithFormat(isSpecial ..
            padLeft(itemName, max_ln, " ") ..
            "&0 " ..
            padLeft(amountMovedEver, 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart * 60), 7, " ") ..
            "p/min" .. moreThanBefore)
        --printWithFormat(isSpecial ..
        --    padLeft("|--", 5, " ") ..
        --    "&0 " ..
        --    padLeft("", 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart * 60), 7, " ") ..
        --    "p/min" .. moreThanAtStart)
        if (max_ln < string.len(itemName)) then
            max_ln = string.len(itemName)
        end
        print ""
    end
    sleep(0.33)
    print("")
    print()

    updateCycle = updateCycle + 1
    if updateCycle % 10 == 9 then
        local file = fs.open("state.count.db", "w")
        file.write(textutils.serialize(movedTable), { compact = true })
        file.close()
    end
end
