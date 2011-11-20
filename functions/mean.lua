
help["sum(table)"] = 'Calculate a sum of the table items'
help["sum(a1, a2, ...)"] = 'Calculate a sum of the arguments'
help["mean(table)"] = 'Calculate a mean value of the table items'
help["mean(a1, a2, ...)"] = 'Calculate a mean value of the arguments'

local function count(t,...)
    return t==nil and 0 or type(t)=='table' and count(unpack(t))+count(...) or
           1+count(...)
end

function sum(t,...)
    return t==nil and 0 or type(t)=='table' and sum(unpack(t))+sum(...) or
           t+sum(...)
end

function mean(...)
    local n=count(...)
    return n>0 and sum(...)/n or 0
end
