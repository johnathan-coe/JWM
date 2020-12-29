local lua =  {}

-- Returns whether a string ends with 'ending'
function lua.endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

-- Retruns whether a string starts with 'Start'
function string.startsWith(String,Start)
   return string.sub(String, 1, string.len(Start)) == Start
end

return lua
