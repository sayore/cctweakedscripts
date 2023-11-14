local json = require "/eget/libs/json"

function checkIsInstalled(appName)
    return fs.exists("/apps/" .. appName .. "/" .. appName)
end

function install(repoURL, appName, depth, depthN)
    if depthN == nil then depthN = 0 end
    if depth == nil then
        printlnWithFormat("Installing " .. appName)
        depth = "&7-"
    else
        printlnWithFormat(depth .. " Installing " .. appName)
    end

    depth = string.rep("&8|",depthN) .. depth

    local pathToAppDir = "/apps/" .. appName .. "/"
    writeAbs(pathToAppDir .. appName .. ".lua", download(repoURL  .. pathToAppDir .. appName .. ".lua"))
    writeAbs(pathToAppDir .. "version", download(repoURL .. pathToAppDir .. "version"))
    local success = writeAbs(pathToAppDir .. "package.json", download(repoURL .. pathToAppDir .. "package.json"))

    if success ~= false and fs.exists(pathToAppDir .. "package.json") == true then
        --print(pathToAppDir .. "package.json")
        local file = fs.open(pathToAppDir .. "package.json", "r")
        local fileContent = file.readAll()
        file.close()
        --print(fileContent)

        local jsonResult = json.decode(fileContent)

        if (jsonResult['dependencies'] ~= nil) then
            for key, value in pairs(jsonResult['dependencies']) do
                if checkIsInstalled(key) then
                    printlnWithFormat(depth .. colors.green .. " Package depends on " .. key .. "..")
                    printlnWithFormat(depth .. "&5 is installed!")
                else
                    printlnWithFormat(depth .. " Package depends on " .. key .. " ..")
                    install(repoURL, key, depth, depthN + 1)
                    print(depth .." has been installed!")
                end
            end
        end
    end

    if (depthN==0) then
        printlnWithFormat("&5has been installed!")
    else
        printlnWithFormat(depth .. " &5has been installed!")
    end
end

function installLib()

end

return { install = install }