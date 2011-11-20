if not rawget(fl_scripts, 'my_memory') then
   rawset(fl_scripts, 'my_memory', {})
end
local my_memory=fl_scripts.my_memory

--- Effortless select
-- @usage When called first time remembers current position, otherwise selects the block between previous position and current.
-- @param column Determines whether the block should be of column type.
function exselect(column)
    local sel = my_memory.exselect
    local info = editor.GetInfo()
    if sel then
        local l1,p1,l2,p2=sel.CurLine,sel.CurPos,info.CurLine,info.CurPos
        if l1>l2 then
            l1,l2=l2,l1
            p1,p2=p2,p1
        end
        if (column or l1==l2) and p2<p1 then
            p1,p2=p2,p1
        end
        editor.SetPosition(nil,{CurLine=l1,CurPos=p1})
        editor.Select(nil,column and 'BTYPE_COLUMN' or 'BTYPE_STREAM',l1,p1,p2-p1+1,l2-l1+1)
        editor.SetPosition(nil,info)
        my_memory.exselect=nil
    else
        my_memory.exselect={CurLine=info.CurLine, CurPos=info.CurPos }
    end
    editor.Redraw()
end

local call=(...)[1]
if call then
    setfenv(loadstring(call), getfenv(1))()
    return
end
