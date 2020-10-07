local Mat = import("$.Material")

local weights = {}

-- Points for each element
weights.weights =  {COAL=1,
                    LEATHER=1,
                    REDSTONE=2,
                    QUARTZ=3,
                    LAPIS_LAZULI=3,
                    IRON_INGOT=4,
                    GOLD_INGOT=5,
                    ENDER_PEARL=5,
                    EMERALD=5,
                    DIAMOND=6,
                    NETHERITE_INGOT=7,
                    ENDER_EYE=7,
                    NETHER_STAR=10,
                    BEACON=10,
                    HEART_OF_THE_SEA=10,
                    -- Blocks are 9x individual points
                    COAL_BLOCK=9,
                    REDSTONE_BLOCK=18,
                    QUARTZ_BLOCK=27,
                    LAPIS_LAZULI_BLOCK=27,
                    IRON_BLOCK=36,
                    GOLD_BLOCK=45,
                    DIAMOND_BLOCK=54,
                    NETHERITE_BLOCK=63}

-- Compute wealth of a chest
function weights.sumFromChest(chestBlock)
    -- Grab chest content
    local inv = chestBlock:getState():getSnapshotInventory()

    -- Sum of points for this chest
    local sum = 0
    
    -- For all items of interest, weights in weights.lua
    for item, value in pairs(weights.weights) do
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

return weights
