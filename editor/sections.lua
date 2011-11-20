context.config.register{key='flsections', inherit=true, path='fl_scripts', name='section'}
local editors=ctxdata.editors

local smenu=require"far2.searchmenu"

local converter=editor.EditorToOEM or function(a) return a end

local function check_pattern(n_start, n_local, strings, pattern)
    local str
    local n_global=n_start+n_local-1
    if not strings[n_global] then
        str=editor.GetString(nil,n_global,2)
        if not str then return end
        strings[n_global]=str
    else
        str=strings[n_global]
    end

    local match=false
    if type(pattern)=='string' then
        match=str:match(pattern)
        if match then
            return { text = string.format('%4i ³ %s', n_global+1 , converter(match)), line=n_global }
        end
    elseif type(pattern)=='table' then
        if pattern.multiline then
            for i, p in ipairs(pattern) do
                local cmatch=check_pattern(n_global, i, strings, p)
                if not cmatch then return false end
                if i==(pattern.linetoshow or 1) then
                    match=cmatch
                end
            end
            return match
        else
            for i, p in ipairs(pattern) do
                match=check_pattern(n_start, n_local, strings, p)
                if match then return match end
            end
        end
    end

    return false
end

local function find_sections(pattern)
    local editinfo = editor.GetInfo()
    local filename = editinfo.FileName
    local lines = editinfo.TotalLines
    local list={}
    local strings={}
    local menu_pos=0
    for linen=0,lines-1 do
        local item=check_pattern(linen, 1, strings, pattern)
        if item then
            item.text=item.text:gsub('&', '&&')
            table.insert(list, item)
            if editinfo.CurLine>=linen then
                menu_pos = menu_pos+1
            end
        end
        strings[linen]=nil
    end
    if #list==0 then
        editor.SetPosition(nil,editinfo)
        return
    end
    local key,f = smenu( { Flags = {FMENU_WRAPMODE=1},
                           Title=filename:match('.+[/\\](.+)',1), HelpTopic="Contents", SelectIndex=menu_pos},
                           list)
    if key and key.line then
        local kline=key.line
        editor.SetPosition(nil,kline,0,0,kline<10 and 0 or kline-10)
    else
        editor.SetPosition(nil,editinfo)
    end
end

local function sections()
    local cfg = editors.current.flsections
    if not cfg then return end
    find_sections(cfg.pattern)
end

sections()
