local json = require("/eget/libs/json")
local testLib = require("/apps/testLib/testLib")

print("Im a Test Program with a test dependency downloaded by eget!")

print("The test dependency gives ma a function that can tell you that it has been imported!");
print(testLib.someFunction())
