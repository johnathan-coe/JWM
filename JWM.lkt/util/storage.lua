local storage =  {}

local signs = plugin.getStorageObject("signs.json")
local gson = require("util.gson")
local bukkit = require("util.bukkit")
local endsWith = require("util.str").endsWith
local Location = import("$.Location")
-- Bukkit
local Mat = import("$.Material")

-- Given a location, determine if it points to a valid sign
function storage.validSign(s, allowBlank)
    local allowBlank = allowBlank or false
    local block = s:getBlock()

    -- Check that this is a wall sign
    if (not endsWith(block:getType():toString(), "WALL_SIGN")) then
        return false
    end

    -- Ensure sign is on a chest
    local chest = bukkit.blockFromWallSign(block)
    if (not (chest:getType() == Mat:getMaterial("CHEST"))) then
        return false
    end

    -- Ensure sign starts with '-'
    local signLines = util.getTableFromArray(block:getState():getLines())
    local group = signLines[1]
    if (allowBlank and group == "") then
    else
        if (group:sub(1,1) ~= "-") then
            return false
        end
    end

    return true
end

-- Return table of valid locations from input table
local function prune(t)
    local pruned = {}
    
    for _, loc in pairs(t) do
        if (storage.validSign(loc)) then
            table.insert(pruned, loc)  
        end
    end
    
    local gone = util.getTableLength(t)-util.getTableLength(pruned)
    if (gone > 0) then
        logger.info("Pruned "..gone)
    end

    return pruned
end

function storage.saveTable(t)
    local jArr = newInstance("com.google.gson.JsonArray")
    for _, loc in pairs(t) do
        jArr:add(gson.Gson:toJsonTree(loc:serialize()))
    end

    signs:setValue("signs", jArr)
    signs:save()
end

-- Load table
-- Only disable pruning if you know what you're doing
function storage.loadTable(pruning)
    if pruning == nil then
        pruning = true
    end

    if signs:getValue("signs") == nil then
        return {}
    else
        -- Table of Location
        local t = {}

        -- Build table using iterator
        local iter = signs:getValue("signs"):iterator()
        while iter:hasNext() do
            local map = gson.decode(iter:next(), "java.util.Map")
            local loc = Location:deserialize(map)
            table.insert(t, loc)
        end
        
        if pruning then
            t = prune(t)
        end

        return t
    end
end

-- Register a sign, returns an info message
function storage.register(signBlock)
    -- Location of this sign
    local loc = signBlock:getLocation() 

    -- Check if sign is valid, allow blank text as we've already verified text
    if (not storage.validSign(loc, true)) then
        return "Sign ineligible..."
    end

    -- Load signs
    local signTable = storage.loadTable()
    
    -- Check if sign is already on chest
    local chest = bukkit.blockFromWallSign(signBlock)
    for _, s in pairs(signTable) do
        if (bukkit.blockFromWallSign(s:getBlock()):equals(chest)) then
            return "Chest already registered!"
        end
    end

    -- Append location
    table.insert(signTable, loc)

    -- Save to file
    storage.saveTable(signTable)  
    
    return "Success!"
end

return storage
