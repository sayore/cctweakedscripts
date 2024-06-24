function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- Make sure HTTP API is enabled in the ComputerCraft configuration
if not http then
    error("HTTP API is not enabled. Please enable it in the ComputerCraft configuration.")
end

-- Function to perform HTTP requests
function fetch(url, options)
    options = options or {}
    local method = options.method or "GET"
    local headers = options.headers or {}
    local body = options.body or nil

    local request = {
        url = url,
        method = method,
        headers = headers,
    }

    if body then
        request.body = body
    end

    -- Debug print to see the request details
    print("Fetching URL:", url)
    print("Method:", method)
    print("Headers:", textutils.serialize(headers))
    if body then
        print("Body:", body)
    end

    -- Perform the HTTP request
    http.request(request.url, request.body, request.headers)

    local function handleResponse(event, response)
        if event == "http_success" then
            local res = {
                status = response.getResponseCode(),
                statusText = "OK",
                headers = response.getResponseHeaders(),
                text = function()
                    return response.readAll()
                end,
                json = function()
                    local text = response.readAll()
                    return text and text ~= "" and textutils.unserializeJSON(text) or nil
                end
            }
            return res, nil
        elseif event == "http_failure" then
            local errorMessage = response or "Unknown error"
            return nil, errorMessage
        end
    end

    -- Wait for the HTTP response
    local timer = os.startTimer(10)
    while true do
        local event, param1, param2 = os.pullEvent()
        if event == "http_success" and param1 == url then
            return handleResponse(event, param2)
        elseif event == "http_failure" and param1 == url then
            return handleResponse(event, param2)
        elseif event == "timer" and param1 == timer then
            return nil, "Request timed out"
        end
    end
end


-- Example usage
local url = "http://example.com/api"
local options = {
    method = "GET",
    headers = {
        ["Content-Type"] = "application/json"
    }
}

local response, err = fetch(url, options)
if response then
    print("Status Code:", response.status)
    print("Response Text:", response.text())
else
    print("Error:", err)
end


---
--- Checks if a given value exists in an array.
---
--- @param array table The array to search in.
--- @param search any The value to search for.
--- @return boolean True if the value is found, false otherwise.
---
function any(array, search)
   for key, value in pairs(array) do
       if (value == search) then return true end
   end
   return false
end
---
--- Splits a string into an array of substrings based on a delimiter.
---
--- @param sep string The delimiter to split the string by.
--- @param str string The string to split.
--- @param limit number|nil The maximum number of substrings to return. Defaults to -1 (no limit).
--- @return table, number The array of substrings and the number of substrings returned.
---
function explode(sep, str, limit)
    if not sep or sep == "" then
       return false
    end
    if not str then
       return false
    end
    limit = limit or math.floor(2^53-1)
    if limit == 0 or limit == 1 then
       return {str}, 1
    end
 
    local r = {}
    local n, init = 0, 1
 
    while true do
       local s,e = string.find(str, sep, init, true)
       if not s then
          break
       end
       r[#r+1] = string.sub(str, init, s - 1)
       init = e + 1
       n = n + 1
       if n == limit - 1 then
          break
       end
    end
 
    if init <= #str then
       r[#r+1] = string.sub(str, init)
    else
       r[#r+1] = ""
    end
    n = n + 1
 
    if limit < 0 then
       for i=n, n + limit + 1, -1 do r[i] = nil end
       n = n + limit
    end
 
    return r, n
end

---
--- Adds a value to a table entry. If the entry does not exist, it is created.
---
--- @param table table The table to modify.
--- @param key any The key of the entry to add a value to.
--- @param value any The value to add to the entry.
---
function tableAddToValue(table, key, value)
    if table[key]==nil then
      table[key] = value
   else
      table[key] = table[key]+value
    end
end

local random = math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9)))
---
--- Generates a universally unique identifier (UUID).
---
--- @return string The generated UUID.
---
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
---@diagnostic disable-next-line: redundant-return-value
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

---
--- Downloads a file from a given URL.
---
--- @param url string The URL of the file to download.
--- @return handle|boolean The handle to the downloaded file, or false if the download failed.
---
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

---
--- Reads the entire contents of a file.
---
--- @param filepath string The path of the file to read.
--- @return string The contents of the file.
---
function readAll(filepath) 
   local file = fs.open(filepath, "w")
   local filedata = file.readAll()
   file.close()
   return filedata
end

---
--- Writes the contents of a handle to a file.
---
--- @param filepath string The path of the file to write to.
--- @param handle handle The handle containing the data to write.
--- @param loud boolean Whether to print status messages. Defaults to false.
--- @return boolean Whether the write was successful.
---
function writeAbs(filepath, handle, loud)
    --print(filepath)
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
 
---
--- Downloads a file from a given URL and writes it to a specified location.
---
--- @param url string The URL of the file to download.
--- @param filepath string The path where the downloaded file should be saved.
--- @param loud boolean Whether to print status messages. Defaults to false.
--- @return boolean Whether the download and write operation was successful.
---
function downloadAndWrite(url, filepath, loud)
    -- Perform the HTTP request to download the file
    http.request(url)
 
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
    until url == url
 
    -- If handle is false, download failed
    if not handle then
        return false
    end
 
    -- Read all data from the handle
    local filedata = handle.readAll()
    handle.close()
 
    -- Write the downloaded data to the specified file
    local file = fs.open(filepath, "w")
    file.write(filedata)
    file.close()
 
    -- Return true to indicate success
    return true
 end
 

 function printWithFormat(a)
    printColoredString(a .. "\n (printWithFormat is deprecated. Use printColoredString instead)")
 end
 
 function printlnWithFormat(a)
    printWithFormat(a)
    print(" ")
 end
 


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

function printColoredString(str)
    local function setColor(colorCode, isBackground)
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
        local char = str:sub(i, i)
        if char == "&" then
            local nextChar = str:sub(i+1, i+1)
            if nextChar == "r" then
                resetColors()
                i = i + 2
            elseif colorsMap[nextChar] then
                setColor(colorsMap[nextChar], false)
                i = i + 2
            elseif #str >= i+2 and colorsMap[nextChar] and colorsMap[str:sub(i+2, i+2)] then
                setColor(colorsMap[nextChar], false)
                setColor(colorsMap[str:sub(i+2, i+2)], true)
                i = i + 3
            else
                -- If the sequence is invalid, skip the '&' and continue
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

function printlnColoredString(str)
    --print("b"..str)
    printColoredString(str)
    print("")
end

---
--- Prints the given arguments on the same line without overwriting old output.
---
--- @param ... The arguments to print.
---
function printInlineWithColor(str)
    -- Determine current cursor position
    local x, y = term.getCursorPos()
    
    -- Move cursor to beginning of the line
    term.setCursorPos(1, y)
    
    -- Clear the line to the right of the cursor
    term.clearLine()
    
    -- Write the output to the terminal
    printColoredString(str)
end

 function strjoin(delimiter, list)
    local len = getn(list)
    if len == 0 then
        return ""
    end
    local string = list[1]
    for i = 2, len do
        string = string .. delimiter .. list[i]
    end
    return string
 end
 
 return {
    dump = dump, 
    explode=explode,
    download = download,
    writeAbs=writeAbs,
    tableAddToValue = tableAddToValue,
    printWithFormat=printWithFormat,
    printlnWithFormat=printlnWithFormat,
    uuid = uuid,
    any=any,
    strjoin=strjoin
 }