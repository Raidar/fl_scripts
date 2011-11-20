context.config.register{key='flcomments', inherit=true, path='fl_scripts', name='comment'}
local config = ctxdata.config
local editors=ctxdata.editors

local smenu=require"far2.searchmenu"

local typ=nil
local comment=nil
local filename = nil

local method_text = nil
local method_env=nil
local method_genv={}

local defer_list=nil

local handler = nil

--------------------------------------------------------------------------------
--define some useful functions to use here ant from a template
setmetatable(method_genv,{ __index = function(s,i) return _G[i] end} )
local function push(str,nonewline)
    local lastline = editor.GetInfo().TotalLines-1
    editor.SetPosition(nil,{CurLine=lastline})
    editor.InsertText(nil,str)
    if not nonewline then editor.InsertString() end
end
local function defer(funct)
    --- delay function call untill file is fully inserted
    table.insert(defer_list,funct)
end
local function here()
    local pos=editor.GetInfo()
    defer(function() editor.SetPosition(nil,pos) end)
end
method_genv.here=here
method_genv.defer=defer
method_genv.push=push

--------------------------------------------------------------------------------
local function compile(str)
    return setfenv(loadstring(str),method_env)
end
local function eval(found,str)
    if str=='' then return '@' end
    local res,method=pcall(compile,str)
    if res then
        return tostring(method() or '')
    end
    return '!!!error!!!'
end

local function strings_pusher(str)
    local newline = str:gsub('(@@(.-)@@)',eval)
    push(newline)
end
local function code_collector(str)
    if str:sub(1,#comment)==comment then
        table.insert(method_text,str:sub(#comment+1))
    else
        if #method_text~=0 then
            local res,method = pcall(compile,table.concat(method_text,' '))
            if res then method() end
        end

        handler = strings_pusher
        handler(str)
    end
end

--------------------------------------------------------------------------------
local function init()
    filename=editor.GetInfo().FileName
    local cfgtable=editors.current
    typ=cfgtable.type
    local defcomment=config.flcomments.default
    if not typ or win.GetFileAttr(filename) then return false end
    comment = (( cfgtable.flcomments or defcomment).line or defcomment.line)..'@@'

    handler = code_collector
    method_text,defer_list,method_env={},{},setmetatable( {},{ __index = function(s,i) return method_genv[i] end} )
    return true
end

--------------------------------------------------------------------------------
local function load_template(f)
    for line in io.lines(f)       do handler(line) end
    for _,v  in pairs(defer_list) do v()           end
end

--------------------------------------------------------------------------------
function fl_scripts.templates_menu()
    if not init() then return end
    local items={}
    local path_begin=far.PluginStartupInfo().ModuleName:match(".+[/\\]")..'scripts\\fl_scripts\\'
    local types=ctxdata.config.types
    local pathU, pathG = path_begin..'templates_user\\', path_begin..'templates\\'

    local attr=nil
    local inhtype=typ
    local path
    while inhtype do
        path=pathU..inhtype
        --far.Message(path)
        attr=win.GetFileAttr(path)
        if attr then break end

        path=pathG..inhtype
        --far.Message(path)
        attr=win.GetFileAttr(path)
        if attr then break end

        inhtype=types[inhtype].inherit
    end
    if not attr or not attr:find 'd' then return end

    for _,v0 in ipairs( far.GetDirList(path) ) do
        local fil=v0.FileName
        attr=win.GetFileAttr(fil)
        if attr and not attr:find 'd' then
            table.insert(items,{text=fil:match '[^\\/]+$', path=fil })
        end
    end
    local key,i=smenu({Flags = {FMENU_WRAPMODE=1, FMENU_AUTOHIGHLIGHT=1}, Title='Templates for '..filename:match('.+[/\\](.+)',2), HelpTopic="Contents"},items)
    if i and key then load_template(key.path) end
end
