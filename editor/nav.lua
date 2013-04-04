context.config.register{key='flnav', inherit=true, path='fl_scripts', name='nav'}

local smenu=require"far2.searchmenu"
local wrapmenu=require 'fl_scripts/utils/wrapmenu'
local clear_path = require 'fl_scripts/utils/clear_path'
local F=far.Flags

local buildlist  --predefine function name
local find_files
local function init()
    local currented=ctxdata.editors.current
    local typ=currented.type
    local cfg=currented.flnav
    if not cfg then return end
    local editorinfo=editor.GetInfo()
    local list={}
    list.cfg=cfg
    list.exclude_dir={}
    list.filename=editorinfo.FileName
    list.editorcurline=editorinfo.CurLine
    list.found={}
    return list
end

local function nav_generator(item)
    if type(item.sub)=='table' then return end
    local items={}
    local filename=item.file
    item.sub={ {Title=filename:match('.+[/\\](.+)',2), Flags={FMENU_WRAPMODE=1}, use_search=true, freeze_tree=true}, items  }
    local list=item.list
    local cfg=list.cfg

    items.cfg=cfg
    items.exclude_dir={}
    items.filename=filename
    items.editorcurline=0
    items.extensions=cfg.extensions
    items.paths=cfg.paths
    items.patterns=cfg.patterns
    items.found={}
    buildlist(items)

    --add sources
    items.extensions=list.cfg.source_extensions
--    items.propose_creation=true
    items.paths=list.cfg.source_paths
    find_files(items, true)
end

----------------------------------------------------------------------------------------
--  @param goifalone defines whether to open file in editor if file is alone in the list
--  @return searchmenu
--  @description text
--  @see list
local function makemenu(list,goifalone)
    if #list==1 and goifalone then
        return list[1],1
    end
--    table.sort(list, function(a,b) if b.create and not a.create then return true end end )
    local r1,r2=wrapmenu({{
      Flags = {FMENU_WRAPMODE=1},
      Title=list.filename:match('.+[/\\](.+)',2), SelectIndex=list.curitem,
      use_search=true, freeze_tree=true}, list},
      nil, nav_generator)
    return r1,r2

end

----------------------------------------------------------------------------------------
--  @usage text
--  @see makemenu
local function addifexist(list)
    local curpath=list.curpath
    local curmatch=list.curmatch
    local curext=list.curext
    local exclude_dir=list.exclude_dir
    local fullfile = curpath..'\\'..curmatch
    fullfile = clear_path(fullfile)
    local fullfile_ext=fullfile..curext
    if list.filename==fullfile_ext or exclude_dir[fullfile_ext] then return end
    if win.GetFileAttr(fullfile_ext) then
        table.insert(list,{text = string.format('%s',fullfile_ext),file=fullfile_ext,sub=true,list=list})
        exclude_dir[fullfile_ext]=true
        list.found[curmatch]=true
    elseif list.propose_creation and not list.found[curmatch] then
        table.insert(list,{text = string.format('Create %s',fullfile_ext), file=fullfile_ext, list=list, create=true})
        return
    end
    if list.curline==list.editorcurline then
        list.curitem=#list
    end
end

local function iter_extensions(list)
    local extensions=list.extensions
    if extensions then
        for _,ext in pairs(extensions) do
            list.curext=ext
            addifexist(list)
        end
    else
        list.curext=''
        addifexist(list)
    end
end

find_files=function(list, silent)
    local curmatch=list.curmatch
    if not curmatch then return end
    local extensions=list.extensions
    local exclude_dir=list.exclude_dir
    local paths=list.paths
    if not paths or not list.cfg.patterns then
        if not silent then far.Message('No configuration', nil, nil, 'w') end
        return
    end
    local count = far.AdvControl('ACTL_GETWINDOWCOUNT')
    for i=1,count do
        local wind=far.AdvControl('ACTL_GETWINDOWINFO',i)
        local fn=wind.Name
        if wind.Type~=1 and fn:find(curmatch,1,true) and list.filename~=fn and not exclude_dir[fn] then
            exclude_dir[fn]=true
            list.found[curmatch]=true
            table.insert(list,{text=string.format('Editor %i: %s',i,fn), file=fn, sub=true, editor=i, list=list })
        end
    end

    for __,path in pairs(paths) do
        local first = path:sub(1,1)
        if first=='.' then
            list.curpath=list.filename:match('(.+[/\\])',1)..path
            iter_extensions(list)
        elseif first=='%' then
            local env=path:match('%%(.+)%%',1)
            local value=win.GetEnv(env)
            if value then
                for subpath in value:gmatch('[^;]+') do
                    list.curpath=subpath..'\\'
                    iter_extensions(list)
                end
            end
        else
            list.curpath=path..'\\'
            iter_extensions(list)
        end
    end
    local panelinfo=nil
    for p=1,2 do
        panelinfo=panel.GetPanelInfo(-1,p)
        if panelinfo.PanelType==F.PTYPE_FILEPANEL and
                bit64.band(panelinfo.Flags, F.PFLAGS_PLUGIN)==0 then
            list.curpath=panel.GetPanelDirectory(-1,p).Name..'\\'
            iter_extensions(list)
        end
    end
end

buildlist=function(list, silent)
    local cfg=list.cfg
    if not cfg.paths or not cfg.patterns then
        if not silent then far.Message('No configuration', nil, nil, 'w') end
        return
    end
    list.curline = 0
    local ifile=io.open(list.filename)
    if not ifile then
        far.Message('File do not exist or not saved', nil, nil, 'w')
        return
    end
    for line in ifile:lines(list.filename) do
        for _,pattern in pairs(cfg.patterns) do
            list.curmatch=line:match(pattern,1)
            find_files(list)
        end
        list.curline = list.curline + 1
    end
    ifile:close()
end

local function open_editor(item)
    if not item or not item.file then return end
    if item.editor then
        far.AdvControl('ACTL_SETCURRENTWINDOW',item.editor)
        far.AdvControl('ACTL_COMMIT')
    else
        editor.Editor(item.file,nil,nil,nil,nil,nil,{EF_NONMODAL=true, EF_IMMEDIATERETURN=false})
    end
end

function navigate()
    local list=init()
    if not list then return end
    list.extensions=list.cfg.extensions
    list.paths=list.cfg.paths
    buildlist(list)

    --add sources
    list.extensions=list.cfg.source_extensions
    list.curmatch = list.filename:match('([^/\\]+)%.([^%./\\]+)$',1)
--    list.propose_creation=true
    list.paths=list.cfg.source_paths
    find_files(list, true)

    if #list==0 then return end
    local key,f = makemenu(list,true)
    open_editor(key)
end

function navigate_current()
    local list=init()
    if not list then return end
    list.extensions=list.cfg.extensions
    local cur_string = editor.GetString(nil,nil,2)
    list.curline=list.editorcurline
    for _,pattern in pairs(list.cfg.patterns) do
        list.curmatch=cur_string:match(pattern,1)
        list.paths=list.cfg.paths
        find_files(list)
    end
    if #list==0 then return end
    local key,f = makemenu(list,true)
    open_editor(key)
end

function source()
    local list=init()
    if not list then return end
    list.extensions=list.cfg.source_extensions
    list.curmatch = list.filename:match('([^/\\]+)%.([^%./\\]+)$',1)
    list.propose_creation=true
    list.paths=list.cfg.source_paths
    find_files(list)
    if #list==0 then return end
    local key,f = makemenu(list)
    open_editor(key)
end

local function main(call)
    if call then
        setfenv(loadstring(call), getfenv(1))()
        return
    end

    local menu = { { text='&Navigate',call=navigate},{text='Navigate &current',call=navigate_current},{text='Find &source',call=source} }
    local key,item = smenu({Flags = {FMENU_WRAPMODE=1, FMENU_AUTOHIGHLIGHT=1}, Title='Navigation'},menu)
    if key and key.call and item>0 then key.call() end
end

main((...)[1])
