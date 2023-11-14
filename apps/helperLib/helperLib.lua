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

function explode(sep, str, limit)
    if not sep or sep == "" then
       return false
    end
    if not str then
       return false
    end
    limit = limit or mhuge
    if limit == 0 or limit == 1 then
       return {str}, 1
    end
 
    local r = {}
    local n, init = 0, 1
 
    while true do
       local s,e = strfind(str, sep, init, true)
       if not s then
          break
       end
       r[#r+1] = strsub(str, init, s - 1)
       init = e + 1
       n = n + 1
       if n == limit - 1 then
          break
       end
    end
 
    if init <= strlen(str) then
       r[#r+1] = strsub(str, init)
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
    if table[key]~=nil then
        table[key] = table[key]+value
    else
        table[key] = value
    end
end

function stop()
    -- Send a signal over Websocket to stop the program
      local ws = require("websocket")
      local ws, err = ws.connect("ws://localhost:8080")
      if not ws then
        print("Could not connect to server")
        print(err)
        return
      end
end

return {dump = dump, explode=explode, tableAddToValue = tableAddToValue}