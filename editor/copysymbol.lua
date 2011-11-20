------------------------------------------------------------------------------
-- insert a single symbol from the upper or lower line
function copysymbol(down)
    local einfo = editor.GetInfo()
    local l,p = einfo.CurLine,einfo.CurPos+1
    if (l==0 and not down)or (l==einfo.TotalLines-1 and down) then return end
    local str=editor.GetString(nil,l + ( down and 1 or -1 )).StringText
    if not str then return end
    local char = str:sub(p,p)
    if not char then return end
    editor.InsertText(nil,char)
    editor.Redraw()
end

local call=(...)[1]
if call then
    setfenv(loadstring(call), getfenv(1))()
    return
end
