local farselection=require 'fl_scripts/utils/block_iterator'

function jumptoblockbegin()
    for _,str in farselection() do
        editor.SetPosition(nil, {CurPos=str.SelStart})
        break
    end
end

function jumptoblockend()
    local str,line
    for _,str1 in farselection() do
        line,str=_,str1
    end
    if not line then return end
    editor.SetPosition(nil, {CurLine=line, CurPos=str.SelEnd})
    editor.Redraw()
end

local call=(...)[1]
if call then
    setfenv(loadstring(call), getfenv(1))()
    return
end
