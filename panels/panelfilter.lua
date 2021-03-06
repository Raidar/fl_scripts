-- panelfilter.lua

local pluginDir = far.PluginStartupInfo().ModuleDir
local helpTopic = "<" .. pluginDir .. [[scripts\fl_scripts\doc\>panelfilter]]

context.config.register{key = "flpanelfilter", inherit = false,
                        path = "fl_scripts", name = "panelfilter"}
local F = far.Flags

local redirect_keys = { Up=1, Down=1, Ins=1, PgUp=1, PgDn=1 }

-- packet-scoped "global" variable:
PanelFilter = rawget(getfenv(1), "PanelFilter") or { Mask="" }

local MacroPost = far.MacroPost

-- call filter dialog, open or create _luafilter_, goto filter
local fil_1=[[
    Keys"CtrlI"
    local pos=Menu.Select("_luafilter_",1)
    if pos<0 then
        exit()
    else
        local OffsMask,OffsAttrDir = 2,13
        if pos==0 then
            Keys"Ins CtrlY"
            print("_luafilter_")
            for k=1,OffsAttrDir do Keys("Down") end
            Keys("Space Space Home")
            for k=1,OffsMask do Keys("Down") end
        else
            Keys"F4"
            for k=1,OffsMask do Keys("Down") end
        end
    end
    Keys"CtrlY"
]]

-- after filling filter, close dialog, turn on, call plugin again
local fil_3=[[
    Keys "Enter BS Up + Enter"
    print("lfe:filter")
    Keys"Enter End"
]]

local delfilter=[[
    Keys"CtrlI"
    if Menu.Select("_luafilter_",1)>0 then
        Keys"Del Enter"
    end
    Keys"Esc"
]]

local function filter_macro(str, key)
    MacroPost "Keys'Enter'"
    if key then MacroPost("Keys('"..key.."')") end
    MacroPost(fil_1)
    MacroPost('print "*'..str..'*"')
    MacroPost(fil_3)
end

local function dlg_handler(handle, msg, p1, p2)
    if msg==F.DN_EDITCHANGE then
        PanelFilter.Mask = p2[10]
        filter_macro(PanelFilter.Mask)
    elseif msg==F.DN_CONTROLINPUT or msg==F.DN_INPUT then
        if p2.EventType==F.KEY_EVENT then
            local name = far.InputRecordToName(p2)
            if name=="Esc" then
                MacroPost(delfilter)
            elseif redirect_keys[name] then
                filter_macro(PanelFilter.Mask, name)
            end
        end
    end
end

local function filter()
    local guid = win.Uuid("1d150046-d526-47b5-b35b-7856c8861a4e")
    local items = { { "DI_EDIT",0,0,20,0,  0,  "","",0,"" } }
    local flags={ FDLG_SMALLDIALOG=1, FDLG_NODRAWSHADOW=1, FDLG_NODRAWPANEL=1 }
    local rect=panel.GetPanelInfo(-1, 1).PanelRect
    items[1][4]=rect.right-rect.left-2
    items[1][10]=PanelFilter.Mask
    far.Dialog(guid, rect.left+1, rect.top+1, rect.right-1, rect.top+1,
               helpTopic, items, flags, dlg_handler )
end

local call=(...)[1]
if call=="filter" then
    filter()
elseif call=="delete_filter" then
    MacroPost(delfilter)
end
