
help['fact(n)'] = 'Calculate factorial of n'

local floor=math.floor
local huge=math.huge
local limit=200

local function factSafe(n, p)
    if n>0 then return factSafe(n-1, n*p)
    else return p end
end

function fact(n)
    --
    -- return factorial of n
    --
    local n=floor(n)
    if n>limit  then return huge
    elseif n>0  then return factSafe(n-1, n)
    elseif n==0 then return 1
    end
    return 0
end
