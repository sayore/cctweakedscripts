--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end
-- End of Lua Library inline imports
local ____exports = {}
____exports.DateTimeFormatter = __TS__Class()
local DateTimeFormatter = ____exports.DateTimeFormatter
DateTimeFormatter.name = "DateTimeFormatter"
function DateTimeFormatter.prototype.____constructor(self)
end
function DateTimeFormatter.pad(self, num, length)
    local str = tostring(num)
    while #str < length do
        str = "0" .. str
    end
    return str
end
function DateTimeFormatter.formatGermanDateTime(self, epochTime)
    local localTime = epochTime + ____exports.DateTimeFormatter.timeZoneOffset
    local seconds = math.floor(localTime / 1000)
    local formattedDate = os.date("!*t", seconds)
    local day = ____exports.DateTimeFormatter:pad(formattedDate.day, 2)
    local month = ____exports.DateTimeFormatter:pad(formattedDate.month, 2)
    local year = formattedDate.year
    local hours = ____exports.DateTimeFormatter:pad(formattedDate.hour, 2)
    local minutes = ____exports.DateTimeFormatter:pad(formattedDate.min, 2)
    local secondsStr = ____exports.DateTimeFormatter:pad(formattedDate.sec, 2)
    return (((((((((day .. ".") .. month) .. ".") .. tostring(year)) .. " ") .. hours) .. ":") .. minutes) .. ":") .. secondsStr
end
function DateTimeFormatter.formatISO8601(self, epochTime)
    local localTime = epochTime + ____exports.DateTimeFormatter.timeZoneOffset
    local seconds = math.floor(localTime / 1000)
    local milliseconds = ____exports.DateTimeFormatter:pad(localTime % 1000, 3)
    local formattedDate = os.date("!*t", seconds)
    local year = formattedDate.year
    local month = ____exports.DateTimeFormatter:pad(formattedDate.month, 2)
    local day = ____exports.DateTimeFormatter:pad(formattedDate.day, 2)
    local hours = ____exports.DateTimeFormatter:pad(formattedDate.hour, 2)
    local minutes = ____exports.DateTimeFormatter:pad(formattedDate.min, 2)
    local secondsStr = ____exports.DateTimeFormatter:pad(formattedDate.sec, 2)
    return ((((((((((((tostring(year) .. "-") .. month) .. "-") .. day) .. "T") .. hours) .. ":") .. minutes) .. ":") .. secondsStr) .. ".") .. milliseconds) .. "Z"
end
function DateTimeFormatter.getCurrentUTCTime(self)
    return os.epoch("utc")
end
function DateTimeFormatter.setTimeZoneOffset(self, offset)
    ____exports.DateTimeFormatter.timeZoneOffset = offset
end
DateTimeFormatter.timeZoneOffset = 0
return ____exports
