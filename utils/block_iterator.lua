local function selection_iterator(inv,state)
    if not inv then
        return nil,nil
    end
    if inv>=0 then
        state = state + 1
        if state>=inv then return nil,nil end
        local str=editor.GetString(nil,state,1)
        if str.SelEnd~=0 then return state,str end
    elseif state>=0 then
        local str=editor.GetString(nil,state,1)
        return -1,str
    end
end

local function farselection(usecurline)
    local editinfo=editor.GetInfo()
    local block=editinfo.BlockType
    if block>0 then
        return selection_iterator,editinfo.TotalLines,editinfo.BlockStartLine-1
    elseif usecurline then
        return selection_iterator,-1,editinfo.CurLine
    else
        return selection_iterator,nil,nil
    end
end

return farselection