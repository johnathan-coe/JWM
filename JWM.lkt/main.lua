-- External Dependencies
local storage = require("util.storage")
local sb = require("util.scoreboard")
local weights = require("weights")
local s =      require("util.command_wrappers").senderName
-- Bukkit
local Mat = import("$.Material")

-- Given a WallSign, get the block it's on
local function blockFromWallSign(signBlock)
    -- Get the direction the sign is facing
    local facing = signBlock:getBlockData():getFacing():getDirection()
    
    -- Get the location of the chest
    local chestLocation = signBlock:getLocation() 
    chestLocation:subtract(facing)
    
    -- Return the chest
    return chestLocation:getBlock()
end

-- Compute wealth of a chest
local function wealthFromChestBlock(chestBlock)
    -- Grab chest content
    local inv = chestBlock:getState():getSnapshotInventory()

    -- Sum of points for this chest
    local sum = 0
    
    -- For all items of interest, weights in weights.lua
    for item, value in pairs(weights) do
        -- Lookup name
        local m = Mat:getMaterial(item) 
        -- Get all ItemStacks in chest for this item
        local stacks = inv:all(m)
        -- Loop over each stack
        local stacksTable = util.getTableFromMap(stacks)
        for _, stack in pairs(stacksTable) do
            -- Add value 
            sum = sum + value * stack:getAmount()
        end
    end

    return sum
end


local function endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

-- When we place a sign
plugin.registerEvent("SignChangeEvent", s(function(ev, sender, name) 
    local signLines = util.getTableFromArray(ev:getLines())
    
    -- If user is attempting to register
    if ((util.getTableLength(signLines) > 0) and  -- Sign has text
            (signLines[1]:sub(1, 1) == '-')) then -- Starts with - 
        -- Recognise intent
        sender:sendMessage(
            "Registering chest... If you don't hear back, contact an admin...")
        
        -- Ensure the sign is on a block
        if (not (endsWith(ev:getBlock():getType():toString(), "WALL_SIGN"))) then
            sender:sendMessage("Sign not on a block!")
            return
        end
        
        -- Ensure sign is on chest
        local chest = blockFromWallSign(ev:getBlock())
        if (not (chest:getType() == Mat:getMaterial("CHEST"))) then
            sender:sendMessage("Sign not on chest!")
            return
        end

        -- Location of this sign
        local loc = ev:getBlock():getLocation() 

        -- Get signs
        local signTable = storage.loadTable()
        
        -- Things to ignore
        for _, s in pairs(signTable) do
            -- Ignore deleted signs
            -- TODO: Implement cleanup function
            if (not endsWith(s:getBlock():getType():toString(), "WALL_SIGN")) then
                logger.info("Ignoring deleted sign")
                goto continue
            end
            
            -- If location already in table, ignore
            if (s:equals(loc)) then
                sender:sendMessage("Registered Replacement Sign!")
                refresh(signTable, signLines[1])
                return
            end
            
            -- If already on chest
            if (blockFromWallSign(s:getBlock()):equals(chest)) then
                sender:sendMessage("Chest already registered!")
                return
            end

            ::continue::
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
    local defaultGroup = defaultGroup or "ERROR"
    local wealth = {}
     
    -- Build a new table of valid signs
    local t = {}
    for _, s in pairs(signTable) do
        local block = s:getBlock()
        
        -- Ensure the sign still exists 
        if (not endsWith(block:getType():toString(), "WALL_SIGN")) then
            logger.info("Discarding deleted sign")
            goto continue
        end

        -- Grab sign text
        local signLines = util.getTableFromArray(block:getState():getLines())
        local group = signLines[1]
        if (group == "") then
            group = defaultGroup
        end

        local chest = blockFromWallSign(block)

        -- Verify sign starts with '-'
        if (not (group:sub(1,1) == "-")) then
            logger.info("Discarding invalid sign")
            goto continue
        end
        
        -- Add wealth to sum
        if wealth[group] == nil then
            wealth[group] = wealthFromChestBlock(chest) 
        else
            wealth[group] = wealth[group] + wealthFromChestBlock(chest)
        end
        
        -- Add to table
        table.insert(t, s)

        ::continue::
    end
    
    -- Update sign list
    storage.saveTable(t)
    
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
