local scoreboard = {}

function scoreboard.init()
    local sb = import("org.bukkit.Bukkit"):getScoreboardManager():getMainScoreboard()
    if (sb:getObjective("test") == nil) then
        local obj = sb:registerNewObjective("test", "dummy", "Wealth")
        obj:setDisplaySlot(import("$.scoreboard.DisplaySlot").SIDEBAR)
    end
end

function scoreboard.pushFromTable(t) 
    -- Grab main scoreboard
    local sb = import("org.bukkit.Bukkit"):getScoreboardManager():getMainScoreboard()
    
    -- Unregister old objective
    local obj = sb:getObjective("test")
    obj:unregister()

    -- Purge old scores
    local obj = sb:registerNewObjective("test", "dummy", "Wealth")

    -- Display on sidebar
    obj:setDisplaySlot(import("$.scoreboard.DisplaySlot").SIDEBAR)

    -- Add to scoreboard
    for i, val in pairs(t) do
        obj:getScore(i:sub(2)):setScore(val)
    end
end

return scoreboard
