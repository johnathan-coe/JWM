-- External Dependencies
local storage =  require("util.storage")
local sb =       require("util.scoreboard")
local s =        require("util.command_wrappers").senderName

-- When we place a sign
plugin.registerEvent("SignChangeEvent", s(function(ev, sender, name) 
    local signLines = util.getTableFromArray(ev:getLines())
    
    -- If user is attempting to register
    if ((util.getTableLength(signLines) > 0) and  -- Sign has text
            (signLines[1]:sub(1, 1) == '-')) then -- Starts with - 

        -- Recognise intent
        sender:sendMessage("Attempting to register...")
    
        -- Attempt to register, send feedback to user
        local status = storage.register(ev:getBlock())
        sender:sendMessage(status)
        
        -- Refresh scoreboard, bypass prune on load
        sb.refresh(storage.loadTable(false), signLines[1])
    end
end))


-- When we trigger a reload
plugin.addCommand({description="Reload Stats", name="jwm", runAsync=false}, function(event) 
    sb.refresh(storage.loadTable())
end)

-- When we close a chest
plugin.registerEvent("InventoryCloseEvent", s(function(ev, sender, name) 
    if (ev:getInventory():getType() == import("$.event.inventory.InventoryType").CHEST) then
        logger.info("Chest Closed! Firing refresh")
        sb.refresh(storage.loadTable())
    end
end))

-- Meta
plugin.onEnable(function()
    logger.info("JWM Enabled!")

    -- Init scoreboard 
    sb.init()
end)
