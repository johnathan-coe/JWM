-- External Dependencies
local storage =  require("util.storage")
local bukkit =   require("util.bukkit")
local sb =       require("util.scoreboard")
local weights =  require("weights")
local s =        require("util.command_wrappers").senderName
local endsWith = require("util.lua").endsWith

-- When we place a sign
plugin.registerEvent("SignChangeEvent", s(function(ev, sender, name) 
    local signLines = util.getTableFromArray(ev:getLines())
    
    -- If user is attempting to register
    if ((util.getTableLength(signLines) > 0) and  -- Sign has text
            (signLines[1]:sub(1, 1) == '-')) then -- Starts with - 
        -- Recognise intent
        sender:sendMessage("Registering...")
        
        -- Location of this sign
        local loc = ev:getBlock():getLocation() 
 
        -- Check if sign is valid, allow blanks as we've already verified text
        if (not storage.validSign(loc, true)) then
            sender:sendMessage("Sign ineligible...")
            return
        end

        -- Load signs
        local signTable = storage.loadTable()
        
        -- Check if sign is already on chest
        local chest = bukkit.blockFromWallSign(ev:getBlock())
        for _, s in pairs(signTable) do
            if (bukkit.blockFromWallSign(s:getBlock()):equals(chest)) then
                sender:sendMessage("Chest already registered!")
                return
            end
        end

        -- Append location
        table.insert(signTable, loc)

        -- Save to file
        storage.saveTable(signTable)  
        
        -- Signal success
        sender:sendMessage("Registered!")
 
        refresh(signTable, signLines[1])
    end
end))

-- Populate scoreboard with table and update saved copy
-- Default group is necessary when refreshing within a
-- sign change event as the sign will be blank until
-- the event has finished processing
function refresh(signTable, defaultGroup)
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
    sb.pushFromTable(wealth)
end


-- When we trigger a reload
plugin.addCommand({description="Reload Stats", name="jwm", runAsync=false}, function(event) 
    refresh(storage.loadTable())
end)

-- When we close a chest
plugin.registerEvent("InventoryCloseEvent", s(function(ev, sender, name) 
    if (ev:getInventory():getType() == import("$.event.inventory.InventoryType").CHEST) then
        logger.info("Chest Closed! Firing refresh")
        refresh(storage.loadTable())
    end
end))

-- Meta
plugin.onEnable(function()
    logger.info("JWM Enabled!")

    -- Init scoreboard 
    sb.init()
end)
