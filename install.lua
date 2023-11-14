-- Node will insert the libs here!
local repoURL = "http://cozycatcrew.de:1380"
local wsURL =   "ws://cozycatcrew.de:1380"
local args = { ... }
term.clear()
writeAbs("/eget/libs/installLib.lua",
    download(repoURL .. "/libs/installLib.lua"))
writeAbs("/eget/libs/helper.lua",
    download(repoURL .. "/libs/helper.lua"))
writeAbs("/eget/libs/bignum.lua",
    download(repoURL .. "/libs/bignum.lua"))
writeAbs("/eget/libs/shapedrawer.lua",
    download(repoURL .. "/libs/shapedrawer.lua"))
writeAbs("/eget/libs/json.lua",
    download(repoURL .. "/libs/json.lua"))
writeAbs("/eget/eget.lua",
    download(repoURL .. "/eget.lua"))
writeAbs("/eget.lua",
    download(repoURL .. "/eget.lua"))

print("Done Install of eget!\n")

