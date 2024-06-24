-- Node will insert the libs here!
term.clear()
local timestamp = os.epoch("utc")
local repoURL = "http://lgbtcuties.duckdns.org:1380"


local args = { ... }
checkRepos();
repoURL = getRepo().repoURL
--setAliasIfNotExist("reinstall", "/eget/libs/starter")
local parallelDownloads = {}
local downloadsDone = 0
local filesToDownload = {
    { path = "/eget/libs/checkRepos.lua", url = repoURL .. "/libs/checkRepos.lua" },
    { path = "/eget/libs/installLib.lua", url = repoURL .. "/libs/installLib.lua" },
    { path = "/eget/libs/starter.lua", url = repoURL .. "/libs/starter.lua" },
    { path = "/eget/libs/helper.lua", url = repoURL .. "/libs/helper.lua" },
    { path = "/eget/libs/bignum.lua", url = repoURL .. "/libs/bignum.lua" },
    { path = "/eget/libs/shapedrawer.lua", url = repoURL .. "/libs/shapedrawer.lua" },
    { path = "/eget/libs/json.lua", url = repoURL .. "/libs/json.lua" },
    { path = "/eget/eget.lua", url = repoURL .. "/eget.lua" },
    { path = "/eget.lua", url = repoURL .. "/eget.lua" }
}

for _, file in ipairs(filesToDownload) do
    downloadAndWrite(file.url,file.path)
    downloadsDone = downloadsDone + 1
    printInlineWithColor("&3[Downloaded " .. downloadsDone .. "/" .. #filesToDownload .. "] &0" .. file.path)

end


print("")
print("Done Install of eget! [install took " .. os.epoch("utc") - timestamp .. "ms]\n")

