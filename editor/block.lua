local farselection=require 'fl_scripts/utils/block_iterator'

local function jumptoblockbegin()
    for _,str in farselection() do
        editor.SetPosition(nil, {CurPos=str.SelStart})
        break
    end
end

local function jumptoblockend()
    local str,line
    for _,str1 in farselection() do
        line,str=_,str1
    end
    if not line then return end
    editor.SetPosition(nil, {CurLine=line, CurPos=str.SelEnd})
    editor.Redraw()
end

local call=(...)[1]
if call=='jumpbegin' then jumptoblockbegin()
elseif call=='jumpend' then jumptoblockend()
end
