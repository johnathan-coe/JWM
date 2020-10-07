local storage =  {}

-- Deps
local signs = plugin.getStorageObject("signs.json")
local gson = require("util.gson")
local bukkit = require("util.bukkit")
local Location = import("$.Location")
-- Bukkit
local Mat = import("$.Material")

local function endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

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

function storage.loadTable()
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
        
        -- Prune and return t
        return prune(t)
    end
end

return storage
