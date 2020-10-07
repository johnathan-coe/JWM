local bukkit = {}

-- Given a WallSign, get the block it's on
function bukkit.blockFromWallSign(signBlock)
    -- Get the direction the sign is facing
    local facing = signBlock:getBlockData():getFacing():getDirection()
    
    -- Get the location of the chest
    local chestLocation = signBlock:getLocation() 
    chestLocation:subtract(facing)
    
    -- Return the chest
    return chestLocation:getBlock()
end

return bukkit
