local farselection = require'fl_scripts/utils/block_iterator'

local EditorSetString=editor.SetString
local EditorGetInfo=editor.GetInfo
local EditorRedraw=editor.Redraw

local histControl=editor.UndoRedo
local flags=far.Flags
local startBlock, stopBlock=flags.EUR_BEGIN,flags.EUR_END

local editinfo=nil
local tabsize=nil
local sindent=nil
local sunindent=nil
local function indent(str)
    EditorSetString(nil,nil,sindent..str.StringText)
end

local function unindent(str)
    if str.StringText:find(sunindent) then
        EditorSetString(nil, nil, str.StringText:gsub(sunindent, ''), '')
    end
end

local function indent_h(handler)
    histControl(nil, startBlock)
    editinfo=EditorGetInfo()
    tabsize=editinfo.TabSize
    sindent=string.format('%'..tabsize..'s','')
    sunindent='^'..sindent:gsub('%s','%%s')
    for _,str in farselection(true) do
        handler(str)
    end
    histControl(nil, stopBlock)
    EditorRedraw()
end

function indentleft() indent_h(unindent) end
function indentright() indent_h(indent) end

local call=(...)[1]
if call then
    setfenv(loadstring(call), getfenv(1))()
    return
end
