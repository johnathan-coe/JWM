local lua =  {}

-- Returns whether a string ends with 'ending'
function lua.endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

return lua
