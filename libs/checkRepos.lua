local minRTT = math.huge
local nonLiveRTT = math.huge
local liveRTT = math.huge
local minURL = ""
local minBaseURL = ""
local repoURL = ""
local wsURL = ""

function pingHTTP(url)
  local startTime = os.clock() -- Start time of the ping
  local timeout = 1 -- Timeout duration in seconds

  http.request(url)

  repeat
      local event, param1, param2, param3 = os.pullEvent()
      if event == "http_success" and param1 == url then
          local endTime = os.clock() -- End time of the ping
          local roundTripTime = (endTime - startTime) * 1000 -- Convert to milliseconds
          return roundTripTime
      elseif event == "http_failure" and param1 == url then
          return math.huge -- Return a large number if request fails
      end
      os.sleep(0.05) -- Adjust sleep time as needed
  until os.clock() - startTime >= timeout

  return math.huge -- Return a large number if request times out
end

function checkRepos()
    local repo = getRepo();

    -- Check already set repo is live and if ping is below 15ms right now
    if repo.repoURL and pingHTTP(repo.repoURL.."/live") < 15 then
        return;
    end

    local function getBaseURL(url)
        return url:match("^(http[s]?://[^/]+)") -- Match everything from http(s):// up to the first slash /
    end

    -- Store pending HTTP requests
    local pendingRequests = {}

    -- Iterate over the list of URLs
    for _, url in ipairs({
        "http://5.56.195.51:1380/install.lua",
        "http://lgbtcuties.duckdns.org:1380/install.lua",
        "http://localhost:1380/install.lua",
        "http://cozycatcrew.de/install.lua",
        "http://princess-sayore.ddns.net/install.lua",
        "https://raw.githubusercontent.com/sayore/cctweakedscripts/master/eget.lua",
    }) do
        local baseURL = getBaseURL(url)
        local liveUrl = baseURL:gsub("/?$", "") .. "/live" -- Ensure baseURL ends with '/' before appending '/live'

        local liveRTT = pingHTTP(liveUrl)
        local nonLiveRTT = pingHTTP(url)

        if liveRTT < nonLiveRTT then
            local response = http.get(liveUrl)
            if response and response.getResponseCode() == 200 and response.readAll() == "true" then
                if liveRTT < minRTT then
                    minRTT = liveRTT
                    minURL = url
                    minBaseURL = baseURL

                    print("New Lowest RTT URL: " .. minRTT .. "ms " .. minURL .. " (Live) ")
                end
            end
        else
            if nonLiveRTT < minRTT then
                minRTT = nonLiveRTT
                minURL = url
                minBaseURL = baseURL

                print("New Lowest RTT URL: " .. minRTT .. "ms " .. minURL .. " (Not Live)")
            end
        end
    end

    if minBaseURL ~= "" then
        print("Base URL: " .. minBaseURL)

        repoURL = minBaseURL
        wsURL = "ws" .. minBaseURL:sub(5)

        -- Write the URLs to a JSON file under /eget/mainrepo.json
        local file = fs.open("/eget/mainrepo.json", "w")
        file.write(textutils.serializeJSON({ repoURL = repoURL, wsURL = wsURL, minRTT = minRTT, time = os.time() }))
        file.close()
    else
        print("No valid URL found.")
    end
end

function getRepo()
  local file = fs.open("/eget/mainrepo.json", "r")
  local data = textutils.unserializeJSON(file.readAll())
  file.close()
  return data
end

return {
  checkRepo = checkRepos,
  getRepo = getRepo
}
