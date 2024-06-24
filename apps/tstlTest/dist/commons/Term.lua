--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

local function __TS__StringCharAt(self, pos)
    if pos ~= pos then
        pos = 0
    end
    if pos < 0 then
        return ""
    end
    return string.sub(self, pos + 1, pos + 1)
end
-- End of Lua Library inline imports
local ____exports = {}
____exports.ColorPrinter = __TS__Class()
local ColorPrinter = ____exports.ColorPrinter
ColorPrinter.name = "ColorPrinter"
function ColorPrinter.prototype.____constructor(self)
end
function ColorPrinter.printColoredString(self, str)
    local function setColor(____, colorCode, isBackground)
        if isBackground then
            term.setBackgroundColor(colorCode)
        else
            term.setTextColor(colorCode)
        end
    end
    local function resetColors()
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
    end
    local x, y = term.getCursorPos()
    local i = 1
    while i <= #str do
        local char = __TS__StringCharAt(str, i - 1)
        if char == "&" then
            local nextChar = __TS__StringCharAt(str, i)
            if nextChar == "r" then
                resetColors(nil)
                i = i + 2
            elseif ____exports.ColorPrinter.colorsMap[nextChar] then
                setColor(nil, ____exports.ColorPrinter.colorsMap[nextChar], false)
                i = i + 2
            elseif #str >= i + 2 and ____exports.ColorPrinter.colorsMap[nextChar] and ____exports.ColorPrinter.colorsMap[__TS__StringCharAt(str, i + 1)] then
                setColor(nil, ____exports.ColorPrinter.colorsMap[nextChar], false)
                setColor(
                    nil,
                    ____exports.ColorPrinter.colorsMap[__TS__StringCharAt(str, i + 1)],
                    true
                )
                i = i + 3
            else
                term.setCursorPos(x, y)
                term.write(char)
                x = x + 1
                i = i + 1
            end
        else
            term.setCursorPos(x, y)
            term.write(char)
            x = x + 1
            i = i + 1
        end
    end
end
function ColorPrinter.printlnColoredString(self, str)
    ____exports.ColorPrinter:printColoredString(str)
    print("")
end
function ColorPrinter.printInlineWithColor(self, str)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.clearLine()
    ____exports.ColorPrinter:printColoredString(str)
end
ColorPrinter.colorsMap = {
    ["0"] = colors.white,
    ["1"] = colors.orange,
    ["2"] = colors.magenta,
    ["3"] = colors.lightBlue,
    ["4"] = colors.yellow,
    ["5"] = colors.lime,
    ["6"] = colors.pink,
    ["7"] = colors.gray,
    ["8"] = colors.lightGray,
    ["9"] = colors.cyan,
    a = colors.purple,
    b = colors.blue,
    c = colors.brown,
    d = colors.green,
    e = colors.red,
    f = colors.black
}
____exports.ColorPrinter:printColoredString("&1Hello &2world&r!")
return ____exports
