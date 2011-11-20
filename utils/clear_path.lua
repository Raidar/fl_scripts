--- Clears the path
-- @param str path
-- @return cleared path
-- @usage Repalces all \ by /
-- @usage Gets rid of \.\, \..\, \\ and \$
local function clear_path(str, div)
    local div=div or '\\'
    return (str..'/'):gsub('\\','/'):gsub('[^/]+/%.%./','/'):gsub('/%./','/'):gsub('//+','/'):gsub('/+$',''):gsub('[\\/]', div)
end

return clear_path