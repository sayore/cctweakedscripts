local json = require("/eget/libs/json")
local testLib = require("/apps/testLib/testLib")

print("Im a Test Program with a test dependency downloaded by eget!")

print("The test dependency gives ma a function that can tell you that it has been imported!");
--print(testLib.someFunction())

local colorsMap = {
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
  ["a"] = colors.purple,
  ["b"] = colors.blue,
  ["c"] = colors.brown,
  ["d"] = colors.green,
  ["e"] = colors.red,
  ["f"] = colors.black,
}

