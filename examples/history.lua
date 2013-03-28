local smenu=require"far2.searchmenu"

local mFlags={ Flags = {FMENU_WRAPMODE=1}, Title='', Bottom=nil, search_plain=true }
local F=far.Flags
local regkey=far.PluginStartupInfo().RootKey:match('(.+)\\Plugins')

local function get_history(key,value)
    local v, typ = win.GetRegKey("HKCU", key, value), ''
    if not v then
        far.Message( ("The is no history or error.\nRegistry message:%s"):format(typ),"History",nil,'w')
        return
    end
    local st,en=1,v:find('\000')
    local items={}
    while st<#v do
        local text=v:sub(st,en)
        table.insert(items, 1, { text=text, file=text })
        st,en=en+1,v:find('\000',en+1)
    end

    mFlags.SelectIndex=#items
    return smenu(mFlags,items)
end

local function get_view_history()
    local v,typ=far.GetRegKey('SavedViewHistory','Lines'),''
    local t=far.GetRegKey('SavedViewHistory','Types')
    if not v or not t then
        far.Message( ("The is no history or error.\nRegistry message:%s"):format(typ),"History",nil,'w')
        return
    end

    local st,en=1,v:find('\000')
    local items={}
    local i=1
    while st<#v do
        local text=v:sub(st,en)
        local typ=tonumber(t:sub(i,i))
        table.insert(items, 1, { text=string.format('%s: %s',typ==1 and 'Editor' or 'Viewer',text), file=text, typ=typ })
        st,en=en+1,v:find('\000',en+1)
        i=i+1
    end

    mFlags.SelectIndex=#items
    return smenu(mFlags,items)
end

function commands_history()
    mFlags.Title='Commands history'
    local item,i=get_history('SavedHistory','Lines')
    if item and item.text then
        panel.SetCmdLine(nil,item.text)
    end
end

function dirs_history()
    mFlags.Title='Folders history'
    local item,i=get_history('SavedFolderHistory','Lines')
    if item and item.text then
        panel.SetPanelDirectory(nil,1,item.text)
    end
end

function view_history()
    mFlags.Title='View history'
    local item,i=get_view_history()
    if item and item.text then
        if item.typ==1 then
            editor.Editor(item.file,nil,nil,nil,nil,nil,F.EF_NONMODAL)
        else
            viewer.Viewer(item.file,nil,nil,nil,nil,nil,F.EF_NONMODAL)
        end
    end
end

local call=...
if call then
    setfenv(loadstring(call), getfenv(1))()
    return
end
