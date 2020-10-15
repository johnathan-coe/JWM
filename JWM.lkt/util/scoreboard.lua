local storage =  require("util.storage")
local bukkit = require("util.bukkit")
local weights =  require("weights")

local scoreboard = {}

-- Initialise scoreboard
function scoreboard.init()
    local sb = import("org.bukkit.Bukkit"):getScoreboardManager():getMainScoreboard()
    if (sb:getObjective("test") == nil) then
        local obj = sb:registerNewObjective("test", "dummy", "Wealth")
        obj:setDisplaySlot(import("$.scoreboard.DisplaySlot").SIDEBAR)
    end
end

-- Push data from table to scoreboard
local function pushFromTable(t) 
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

-- Populate scoreboard with table and update saved copy
-- Default group is necessary when refreshing within a
-- sign change event as the sign will be blank until
-- the event has finished processing
function scoreboard.refresh(signTable, defaultGroup)
    local defaultGroup = defaultGroup or " ERROR"
    local wealth = {}

    for _, s in pairs(signTable) do
        local block = s:getBlock()

        -- Grab sign text
        local signLines = util.getTableFromArray(block:getState():getLines())
        local group = signLines[1]
        if (group == "") then
            group = defaultGroup
        end

        local chest = bukkit.blockFromWallSign(block)

        -- Add wealth to sum
        if wealth[group] == nil then
            wealth[group] = weights.sumFromChest(chest) 
        else
            wealth[group] = wealth[group] + weights.sumFromChest(chest)
        end
    end
    
    -- Update sign list
    storage.saveTable(signTable)
    
    -- Push to scoreboard
    pushFromTable(wealth)
end

return scoreboard
