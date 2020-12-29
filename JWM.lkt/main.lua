-- External Dependencies
local storage =  require("util.storage")
local sb =       require("util.scoreboard")
local str =      require("util.str")
local CHEST =    import("$.event.inventory.InventoryType").CHEST 

local function signPlaced(ev)
    local sender = event:getPlayer()
    local signLines = util.getTableFromArray(ev:getLines())
    
    -- If user is attempting to register
    if ((util.getTableLength(signLines) > 0) and  -- Sign has text
            str.startsWith(signLines[1], '-')) then

        -- Recognise intent
        sender:sendMessage("Attempting to register...")
    
        -- Attempt to register, send feedback to user
        local status = storage.register(ev:getBlock())
        sender:sendMessage(status)
        
        -- Refresh scoreboard, bypass prune on load
        sb.refresh(storage.loadTable(false), signLines[1])
    end
end

local function inventoryClosed(ev)
    if (ev:getInventory():getType() == CHEST) then
        logger.info("Chest Closed! Firing refresh")
        sb.refresh(storage.loadTable())
    end
end

local function jwm(ev)
    sb.refresh(storage.loadTable())
end

-- Bind functions
plugin.registerEvent("InventoryCloseEvent", inventoryClosed)
plugin.addCommand({description="Reload Stats", name="jwm", runAsync=false}, jwm)
plugin.registerEvent("SignChangeEvent", signPlaced)

-- Meta
plugin.onEnable(function() 
    logger.info("JWM Enabled!")

    -- Init scoreboard 
    sb.init()
end)
