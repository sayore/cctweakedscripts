local json = require "/eget/libs/json"

function download(url) 
    local myURL = url
    http.request(myURL)
    local event, url, handle
    repeat
        local ev = {os.pullEvent()}
        if ev[1]=="http_success" then
            url = ev[2]
            handle = ev[3]
        end
        if ev[1] == "http_failure" then
            print("File could not be found -- exiting")
            return false
        end

    until url == myURL

    return handle
end

function writeAbs(filepath, handle)
    print("Trying to get "..filepath)
    -- In case we don't get data back return false!
    if(handle==false) then return false end
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

function install(appName)
    local path = "/apps/"..args[2].."/"..args[2]
    writeAbs(path..".lua",               download(repoURL.."/"..path..".lua"))
    if writeAbs(path..".json",               download(repoURL.."/package.json"))~=nil then
        local file = fs.open(path..".json", "w")
        json.decode(file.readAll())
        file.close()

        print(" Dependencies: "..json['dependencies'])
    end
end

function installLib()

end

return {install = install}