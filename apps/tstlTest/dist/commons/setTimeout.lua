-- setTimeout.lua

local setTimeout = {}

-- Array to store timeout and interval tasks
local tasks = {}

-- Main loop function (default implementation)
local function defaultMainLoop()
    while true do
        local event, param = os.pullEvent()

        if event == "timer" then
            for i = #tasks, 1, -1 do
                local task = tasks[i]
                if param == task.timer then
                    -- Execute callback and handle based on type
                    task.callback()

                    if task.type == "interval" then
                        -- Restart interval timer
                        task.timer = os.startTimer(task.interval)
                    else
                        -- Remove timeout task after execution
                        table.remove(tasks, i)
                    end
                end
            end
        end

        -- Additional main loop logic can be added here
        -- For example, handling other types of events or tasks

        print("main loop not set")
        return
    end
end

-- Initialize setTimeout with a custom main loop
function setTimeout.init(mainLoop)
    if type(mainLoop) == "function" then
        setTimeout.mainLoop = mainLoop
    else
        setTimeout.mainLoop = defaultMainLoop
    end
end

-- Start the main loop to handle events and tasks
function setTimeout:start()
    setTimeout.mainLoop()
end

-- Schedule a timeout task
function setTimeout:setTimeout(callback, delay)
    local timer = os.startTimer(delay)

    -- Store the task in the tasks array
    local task = {
        type = "timeout",
        timer = timer,
        callback = callback,
        delay = delay
    }
    table.insert(tasks, task)

    -- Return task object for clearTimeout
    return task
end

-- Schedule an interval task
function setTimeout:setInterval(callback, interval)
    local timer = os.startTimer(interval)

    -- Store the task in the tasks array
    local task = {
        type = "interval",
        timer = timer,
        callback = callback,
        interval = interval
    }
    table.insert(tasks, task)

    -- Return task object for clearInterval
    return task
end

-- Clear a timeout task
function setTimeout:clearTimeout(task)
    for i = #tasks, 1, -1 do
        if tasks[i] == task then
            table.remove(tasks, i)
            break
        end
    end
end

-- Clear an interval task
function setTimeout:clearInterval(task)
    for i = #tasks, 1, -1 do
        if tasks[i] == task then
            table.remove(tasks, i)
            break
        end
    end
end

return setTimeout
