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

function any(array, search)
   for key, value in pairs(array) do
       if (value == search) then return true end
   end
   return false
end

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

function tableAddToValue(table, key, value)
    if table[key]==nil then
      table[key] = value
   else
      table[key] = table[key]+value
    end
end

local random = math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9)))
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

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

function readAll(filepath) 
   local file = fs.open(filepath, "w")
   local filedata = file.readAll()
   file.close()
   return filedata
end

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