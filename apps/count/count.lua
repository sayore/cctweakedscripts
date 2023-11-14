-- eget live count --from=back --to=front
local helper = require "/apps/helperLib/helperLib"
local debug = require "/apps/debugLib/debugLib"
local json = require("/eget/libs/json")
local args = { ... }
local fromSide = "back"
local toSide = "right"
local toMonitor = nil

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
    if startsWith(value, "--monitor=") == true then
        toMonitor = string.sub(value, string.len("--monitor= "))
    end
end

print("FROM " .. fromSide .. " TO " .. toSide .. " INTO MONITOR " .. (toMonitor==nil and "No Monitor" or toMonitor))

local from = peripheral.wrap(fromSide)
local to = peripheral.wrap(toSide)

if peripheral.isPresent(fromSide)~=true and peripheral.hasType(from,"inventory")==false then
    error("From-Peripheral is not present! -- Exiting")
end
if peripheral.isPresent(toSide)~=true then
    error("To-Peripheral is not present! -- Exiting")
end
if peripheral.hasType(from,"inventory")==false then
    error("From-Preipheral is not an inventory! -- Exiting")
end
if peripheral.hasType(to,"inventory")==false then
    error("To-Preipheral is not an inventory! -- Exiting")
end

local monitor = term.current()
if toMonitor~=nil then
    local monitor = peripheral.wrap(toMonitor)
    monitor.setTextScale(0.5)
end
local version = 0
if fs.exists("/apps/count/version") then
    local file = fs.open("/apps/count/version", "r")
    version=file.readAll()
    print("Version file exists!")
    file.close()
end
print("Arguments: ",dump(args))
print("Terminal Redirect! (Build "..version..")")
term.redirect(monitor)
print("Terminal Redirect! 2")
monitor.clear()

monitor.write("HELLO\n")
monitor.setBackgroundColor(colors.black)
local movedTable = {}
local movedSinceStartTable = {}
local movedTableLastUpdate = {}
print("\nStart Cycle") --eget live count -fa
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

local specialItems = {
    ["Lead Ore"]        = "&b",
    ["Ancient Debris"]  = "&1",
    ["Diamond Ore"]     = "&3",
    ["Emerald Ore"]     = "&5",
    ["Gold Ore"]        = "&4",
    ["Iron Ore"]        = "&8",
    ["Glowstone"]       = "&4",
    ["Nikolite Ore"]    = "&9"
}

local specialWords = {
    ["Lead"] = "&b",
    ["Nether"] = "&1",
    ["Diamond"] = "&3",
    ["Emerald"] = "&5",
    ["Copper"] = "&1",
    ["Bronze"] = "&1",
    ["Gold"] = "&4",
    ["Iron"] = "&8",
    ["Steel"] = "&8",
    ["Aluminum"] = "&0",
    ["Glowstone"] = "&4",
    ["Invar"] = "&5",
    ["Nikolite"] = "&9"
}

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
    print("\nRead Clock")
    table.sort(movedTable);
    print("\nSorted Table")
    for i = 1, from.size() do
        local itemdetail = from.getItemDetail(i)
        if itemdetail ~= nil then
            local pushed = from.pushItems(toSide, i, 64)
            local itemName=itemdetail["displayName"]
            helper.tableAddToValue(movedTable,itemName, pushed)
            helper.tableAddToValue(movedSinceStartTable,itemName, pushed)
            helper.tableAddToValue(movedTableLastUpdate,itemName, pushed)
            sendDebugToWS(json.encode({type="sendCountData",data=movedTable}))
        end
    end
    print("\nSend Data to WS")
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
            moreThanAtStart = " (+ " .. movedSinceStartTable[itemName] .. " Pcs)"
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
        if toMonitor~=nil then
            local monitor = peripheral.wrap(toMonitor)
            term.redirect(monitor)
        end

        local file = fs.open("state.count.db", "w")
        file.write(textutils.serialize(movedTable), { compact = true })
        file.close()
    end
end
