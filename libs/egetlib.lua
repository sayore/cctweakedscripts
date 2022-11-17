local json = require "/eget/libs/json"
local helper = require "/eget/libs/helper"

function download(url, loud)
    local myURL = url
    http.request(myURL)
    local event, url, handle
    repeat
        local ev = { os.pullEvent() }
        if ev[1] == "http_success" then
            url = ev[2]
            handle = ev[3]
        end
        if ev[1] == "http_failure" then
            
            return false
        end

    until url == myURL

    return handle
end

function writeAbs(filepath, handle, loud)
    print(filepath)
    -- In case we don't get data back return false!
    if (handle == false) then 
        return false
    end
    local filedata = handle.readAll()
    handle.close()

    local file = fs.open(filepath, "w")
    file.write(filedata)
    file.close()
    -- return true if wwe were succesful writing the data to disk
    return true;
end

function checkVersion()

end

function checkIsInstalled(appName)
    return fs.exists("/apps/" .. appName .. "/" .. appName)
end

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
    writeAbs(pathToAppDir .. appName .. ".lua", download(repoURL .. "/" .. pathToAppDir .. appName .. ".lua"))
    writeAbs(pathToAppDir .. "version", download(repoURL .. "/" .. pathToAppDir .. "version"))
    local success = writeAbs(pathToAppDir .. "package.json", download(repoURL .. "/" .. pathToAppDir .. "package.json"))

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
                    --print(depth .." has been installed!")
                end
            end
        end
    end

    if (depthN==0) then
        printlnWithFormat("&5has been installed!")
    else
        printlnWithFormat(depth .. " &5has been installed!")
    end
    return
end

function installLib()

end

return { install = install }
