local util_command =  {}

-- Provides sender and name to a command
function util_command.senderName(command)
    return function(event)
        local sender = event:getPlayer()
        local name = sender:getName()
        command(event, sender, name)
    end
end

-- Provides sender and name to a command
function util_command.senderNameCMD(command)
    return function(event)
        local sender = event:getSender()
        local name = sender:getName()
        command(event, sender, name)
    end
end
return util_command
