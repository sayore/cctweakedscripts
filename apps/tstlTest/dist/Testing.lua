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
____exports.Testing = __TS__Class()
local Testing = ____exports.Testing
Testing.name = "Testing"
function Testing.prototype.____constructor(self)
    print("hello from constructor" .. tostring(os.time()))
end
function Testing.myfunc(self)
    print("hello from myfunc")
end
Testing.myvar = "hello"
return ____exports
