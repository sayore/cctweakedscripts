-- eget live count --from=back --to=front
local helper = require "/apps/helperLib/helperLib"
local debug = require "/apps/debugLib/debugLib"
local json = require("/eget/libs/json")
local args = { ... }
local fromSide = "back"
local toSide = "right"
local optionShowDepot = false
local optionDetailed = false
local debug=false
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
    if startsWith(value, "--show-depot") == true then
        optionShowDepot=true
    end
    if startsWith(value, "--detailed") == true then
        optionDetailed=true
    end
end

term.clear()
term.setCursorPos(1, 3)
print("Runtime Info")
print("FROM " .. fromSide .. " -> " .. toSide)
print("INTO MONITOR " .. (toMonitor==nil and "No Monitor" or toMonitor))


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
    term.redirect(monitor)
    print("Bound Monitor {"..(monitor and "a monitor" or "???").."}["..toMonitor.."]")
    sleep(1)
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

monitor.setBackgroundColor(colors.black)
local movedTable = {}
local movedSinceStartTable = {}
local movedTableLastUpdate = {}
local currentlyLeftInChestTable = {}

local waitTime = 1
while waitTime >= 0 do
    term.setCursorPos(1, 1)
    print("Starting in         ")
    term.setCursorPos(1, 1)
    print("Starting in " .. waitTime .. "s")
    sleep(0.02)
    waitTime=waitTime-0.02
end

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
function disp_time(time)
    local days = math.floor(time/86400)
    local hours = math.floor((time% 86400)/3600)
    local minutes = math.floor((time%3600)/60)
    local seconds = math.floor((time%60))
    return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end
  
local max_ln = 12
local start = os.clock()
local updateCycle = 0
while true do
    local now = os.clock()
    table.sort(movedTable)
    currentlyLeftInChestTable = {}
    for i = 1, from.size() do
        local itemdetail = from.getItemDetail(i)
        if itemdetail ~= nil then
            local pushed = from.pushItems(toSide, i, 64)
            local itemName=itemdetail["displayName"]
            helper.tableAddToValue(movedTable,itemName, pushed)
            helper.tableAddToValue(movedSinceStartTable,itemName, pushed)
            helper.tableAddToValue(movedTableLastUpdate,itemName, pushed)
            local itemdetail = from.getItemDetail(i)
            if itemdetail ~= nil then
                helper.tableAddToValue(currentlyLeftInChestTable,itemName, itemdetail.count)
            end
            --sendDebugToWS(json.encode({type="sendCountData",data=movedTable}))
        end
    end

    sleep(0.1)
    term.clear()
    monitor.setCursorPos(1, 1)
    term.setCursorPos(1, 1)
    print("Watching Items ["..padRight(string.rep("#",math.floor(updateCycle%20/2)), 10, " ").."] ("..string.format("%.2f",((20*0.25)-updateCycle%20*0.25)).."s | Mode "..(math.floor(updateCycle%60/20)+1).."/3)")

    
    local entry = 0
    for itemName, amountMovedEver in pairsByKeys(movedTable) do
        local perSecond = 0
        local perSecondSinceStart = 0
        if movedSinceStartTable[itemName]~=nil then
            perSecondSinceStart = movedSinceStartTable[itemName] / (now - start)
        end
        local moreThanBefore = ""
        local moreThanAtStart = ""
        local stocked = ""
        if movedTableLastUpdate[itemName] ~= nil and movedTableLastUpdate[itemName] ~= 0 then
            moreThanBefore = " (+ " .. movedTableLastUpdate[itemName] .. " Pcs)"
        end
        if movedSinceStartTable[itemName] ~= nil and movedSinceStartTable[itemName] ~= 0 then
            moreThanAtStart = " (+ " .. movedSinceStartTable[itemName] .. " Pcs)"
        end
        if optionShowDepot==true and currentlyLeftInChestTable[itemName] ~= nil and currentlyLeftInChestTable[itemName] ~= 0 then
            stocked = "Stocked Time: ".. disp_time(currentlyLeftInChestTable[itemName]/perSecondSinceStart) .. " ("..currentlyLeftInChestTable[itemName].."p/"..string.format("%.2f", perSecondSinceStart).."ps)"
        end
        movedTableLastUpdate[itemName] = 0
        local isSpecial = "&0"
        for k2, v2 in pairs(specialWords) do
            if string.find(itemName, k2) then
                isSpecial = v2
            end
        end
        if specialItems[itemName] ~= nil then
            isSpecial = specialItems[itemName]
        end
        if movedSinceStartTable[itemName]~=nil and movedSinceStartTable[itemName] > 0.001 then
            if optionDetailed then
                if (updateCycle%60)<=20 and (updateCycle%40)>=0 then
                    printWithFormat(isSpecial ..
                        padLeft(itemName, max_ln, " ") ..
                        "&0 " ..
                        padLeft(amountMovedEver, 6, " ")
                        "p/s" .. moreThanBefore)
                    print ""
                    printWithFormat(isSpecial .. "   " ..
                        padLeft(string.format("%.2f", perSecondSinceStart), 7, " ").."p/s".. "   " ..
                        padLeft(string.format("%.2f", perSecondSinceStart * 60), 7, " ") .."p/min".. "   " ..
                        padLeft(string.format("%.2f", perSecondSinceStart * 3600), 7, " ") .."p/h")

                end
            else
                if (updateCycle%60)<=20 and (updateCycle%40)>=0 then
                    printWithFormat(isSpecial ..
                        padLeft(itemName, max_ln, " ") ..
                        "&0 " ..
                        padLeft(amountMovedEver, 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart), 7, " ") ..
                        "p/s" .. moreThanBefore)
                end
                if (updateCycle%60)<=40 and (updateCycle%60)>20 then
                    printWithFormat(isSpecial ..
                        padLeft(itemName, max_ln, " ") ..
                        "&0 " ..
                        padLeft(amountMovedEver, 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart * 60), 7, " ") ..
                        "p/min" .. moreThanBefore)
                end
                if (updateCycle%60)<=60 and (updateCycle%60)>40 then
                    printWithFormat(isSpecial ..
                        padLeft(itemName, max_ln, " ") ..
                        "&0 " ..
                        padLeft(amountMovedEver, 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart * 3600), 7, " ") ..
                        "p/h" .. moreThanBefore)
                end
            end
            
            if optionShowDepot==true then
                print ""
                printWithFormat(isSpecial ..
                    stocked)
            end
            print "&0"
        end
        --printWithFormat(isSpecial ..
        --    padLeft("|--", 5, " ") ..
        --    "&0 " ..
        --    padLeft("", 6, " ") .. " " .. padLeft(string.format("%.2f", perSecondSinceStart * 60), 7, " ") ..
        --    "p/min" .. moreThanAtStart)
        if (max_ln < string.len(itemName)) then
            max_ln = string.len(itemName)
        end
        
    end
    sleep(0.25)
    --print("")
    --print()

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
