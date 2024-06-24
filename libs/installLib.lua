json = require("/eget/libs/json")


function checkIsInstalled(appName)
    return fs.exists("/apps/" .. appName .. "/" .. appName)
end

function stringToArray(str)
    -- Remove the surrounding brackets and extra spaces
    str = str:match("^%s*%[(.-)%]%s*$")
    if not str then return {} end

    local array = {}
    for s in str:gmatch('%b""') do
        -- Remove the surrounding quotes
        local item = s:sub(2, -2)
        -- Unescape any escaped quotes within the string
        item = item:gsub('\\"', '"')
        table.insert(array, item)
    end

    return array
end
local function downloadFile(repoURL, pathToAppDir, contentDir, file, callback)
    local url = repoURL .. pathToAppDir .. contentDir .. "/" .. file
    local response, err = fetch(url)

    if response then
        local filePath = pathToAppDir .. contentDir .. "/" .. file
        local fileHandle = fs.open(filePath, "w")
        if fileHandle then
            fileHandle.write(response.text())
            fileHandle.close()
            printlnColoredString("&aDownloaded: " .. filePath .. " to " .. filePath)
        else
            printlnColoredString("&cError opening file for writing: " .. filePath)
        end
    else
        printlnColoredString("&cError downloading file: " .. file .. " -> " .. err)
    end

    if callback then
        callback()
    end
end

local function downloadFiles(repoURL, pathToAppDir, contentDir, files, index, callback)
    if index > #files then
        if callback then
            callback()
        end
        return
    end

    local file = files[index]
    downloadFile(repoURL, pathToAppDir, contentDir, file, function()
        sleep(0.1) -- Yield to allow other tasks to run
        downloadFiles(repoURL, pathToAppDir, contentDir, files, index + 1, callback)
    end)
end

local function fetchAndDownload(repoURL, pathToAppDir, contentDir)
    local response, err = fetch(repoURL .. "/dirAsList" .. pathToAppDir .. contentDir)

    if response then
        local reText = response.text()
        printlnColoredString("\n\nDir DL -> /" .. contentDir .. "&5[" .. response.status .. "]&0")
        printlnColoredString("\n\nDir TO -> /" .. pathToAppDir .. contentDir)

        if response.status == 200 then
            local files = stringToArray(reText)
            printlnColoredString("Downloading " .. #files .. " files...")

            -- Download files asynchronously
            downloadFiles(repoURL, pathToAppDir, contentDir, files, 1, function()
                printlnColoredString("&aAll files downloaded!")
            end)
        else
            printlnColoredString("&cError fetching directory listing: " .. response.status)
        end
    else
        printlnColoredString("&cError fetching directory listing: " .. err)
    end
end



function install(repoURL, appName, depth, depthN)
    if depthN == nil then depthN = 0 end
    if depth == nil then
        printlnColoredString("Installing " .. appName .. "\n")
        depth = "&7-"
    else
        printlnColoredString(depth .. " Installing " .. appName .. "\n")
        
    end

    depth = string.rep("&8|",depthN) .. depth

    local pathToAppDir = "/apps/" .. appName .. "/"
    -- Download App itself
    writeAbs(pathToAppDir .. appName .. ".lua", download(repoURL  .. pathToAppDir .. appName .. ".lua"))
    writeAbs(pathToAppDir .. "version", download(repoURL .. pathToAppDir .. "version"))
    local success = writeAbs(pathToAppDir .. "package.json", download(repoURL .. pathToAppDir .. "package.json"))
-- Function to set alias if it doesn't exist
    
    -- Install a shell starter in /rom/programs/
    --fs.open("/rom/programs/" .. appName .. ".lua", "w"):write("shell.run(\"" .. appName .. "\")"):close()
    
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
                    printlnColoredString(depth .. colors.green .. " Package depends on " .. key .. "..")
                    printlnColoredString(depth .. "&5 is installed!")
                else
                    printlnColoredString(depth .. " Package depends on " .. key .. " ..")
                    install(repoURL, key, depth, depthN + 1)
                    printlnColoredString(depth .." has been installed!\n")
                end
            end
        end
        if (jsonResult['eget'] ~= nil) then
            if (jsonResult['eget']['dependencies'] ~= nil) then
                for key, value in pairs(jsonResult['eget']['dependencies']) do
                    if checkIsInstalled(key) then
                        printlnColoredString(depth .. colors.green .. " Package depends on " .. key .. "..")
                        printlnColoredString(depth .. "&5 is installed!")
                    else
                        printlnColoredString(depth .. " Package depends on " .. key .. " ..")
                        install(repoURL, key, depth, depthN + 1)

                        print(depth .." has been installed!\n")
                    end
                end
            end
            if (jsonResult['eget']['contentDirs'] ~= nil) then
                -- get List of contentDirs
                for i = 1, #jsonResult['eget']['contentDirs'] do
                    local contentDir = jsonResult['eget']['contentDirs'][i]

                    -- Create the directory
                    fs.makeDir(pathToAppDir .. contentDir)
                    
                    local response, err = fetch(repoURL .. "/dirAsList" .. pathToAppDir .. contentDir)
                    fetchAndDownload(repoURL, pathToAppDir, contentDir)
                end
            end
        end
    end

    if (depthN==0) then
        printlnColoredString("&5has been installed!\n")
    else
        printlnColoredString(depth .. " &5has been installed!\n")
    end
end

function installLib()

end

return { install = install }