
help['fib(n)'] = 'Calculate n-th Fibonacci number'

local floor=math.floor
local huge=math.huge

local fibs
local limit=1500
function fib(n)
    --
    -- return n-th Fibonacci number (iterative)
    --
    if n>limit then return huge end
    local n=floor(n)
    fibs={[0]=0, 1, 1}
    for i=3,n do
        if not fibs[i] then
            fibs[i]=fibs[i-1]+fibs[i-2]
        end
    end

    return fibs[n]
end
