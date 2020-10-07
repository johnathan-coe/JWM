local storage =  {}

-- Deps
local signs = plugin.getStorageObject("signs.json")
local gson = require("util.gson")
local Location = import("$.Location")

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

        return t
    end
end

return storage
