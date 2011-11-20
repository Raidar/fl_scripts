local far2dialog=require 'far2.dialog'
local flags=far.Flags

local compiled    = nil
local result      = 0
local raw_result  = nil
local active_item = nil
local arguments   = nil
local items = far2dialog.NewDialog()
local environ = setmetatable({}, { __index=function(t,k) return math[k] or bit64[k] end })
local help={ }

local function load_error(filename, errmsg)
    far.Message( ('Failed to load file %s:\n%s'):format(filename, errmsg) )
end

local function showHelp()
    local message={}
    for k,v in pairs(help) do
        table.insert(message, ('%-20.20s - %s'):format(k, v))
    end
    table.sort(message)
    far.Message(table.concat(message,'\n'), 'Functions:', nil, 'l')
end

local function loadUserFunction(filename, tbl)
    local chunk, errmsg = loadfile(filename)
    local ltbl=setmetatable({help={}}, {__index=_G})
    if not chunk then load_error(filename, errmsg) end
    local ok, errmsg = pcall(setfenv(chunk, ltbl))
    if not ok then load_error(filename, errmsg) end
    for k, v in pairs(ltbl) do
        if k~='help' then tbl[k]=v end
    end
    for k, v in pairs(ltbl.help) do
        help[k]=ltbl.help[k]
    end
    return true
end

local function loadUserFunctions(verbose)
    local functions={}
    local path=far.PluginStartupInfo().ModuleName:match(".+[/\\]")..'scripts\\fl_scripts\\functions'
    local mess='Loading:'
    for _,v0 in ipairs( far.GetDirList(path) ) do
        local fname=v0.FileName
        if not v0.FileAttributes:find 'd' and fname:sub(-4):lower()==".lua" then
            mess=mess..'\n'..fname:match('[^\\/]+$')
            local st=loadUserFunction(fname, functions)
            mess=mess..(st and ' ok' or ' fail')
        end
    end
    mess=mess..'\nLoaded:'
    for k, v in pairs(functions) do
        environ[k]=v
        mess=mess..'\n'..k..' -> '..tostring(v)
    end
    if verbose then far.Message(mess) end
end

local function act_calculate(handle)
    local edt=items.calc
    edt[10]=raw_result
    far.SetDlgItem(handle, edt.id, edt)
    return 0
end

local function act_copy()
    far.CopyToClipboard(active_item[10])
    return 0
end

local function act_insert()
    if arguments.From=='dialog' then
        local id = far.SendDlgMessage(arguments.hDlg, "DM_GETFOCUS")
        local item = far.GetDlgItem(arguments.hDlg, id)
        if item[1]==flags.DI_EDIT or
           item[1]==flags.DI_FIXEDIT or
           item[1]==flags.DI_COMBOBOX
        then
            far.SendDlgMessage(arguments.hDlg, "DM_SETTEXT", id, active_item[10])
        end
    elseif arguments.From=='editor' then
        editor.InsertText(nil, active_item[10])
    elseif arguments.From=='panels' then
        panel.SetCmdLine(nil, active_item[10])
    end
end

items._        = { "DI_DOUBLEBOX",    3,1,72,8,    0,0,0,0,                     "Lua Calc" }
items.calc     = { 'DI_EDIT',         5,2,70,2,    0,'LuaCalc',0,flags.DIF_HISTORY, ''}

items.decfmt   = { "DI_EDIT",         9,3,14,3,    0,0,0,0,                     '%g' }
items.octfmt   = { "DI_EDIT",         9,4,14,4,    0,0,0,0,                     '%o' }
items.hexfmt   = { "DI_EDIT",         9,5,14,5,    0,0,0,0,                     '%#x' }
items.rawfmt   = { "DI_EDIT",         9,6,14,6,    0,0,0,0,                     "%s" }

items.dec      = { "DI_TEXT",         18,3,0,3,    0,0,0,0,                     ''         , update=true, fmt=items.decfmt }
items.oct      = { "DI_TEXT",         18,4,0,4,    0,0,0,0,                     ''         , update=true, fmt=items.octfmt }
items.hex      = { "DI_TEXT",         18,5,0,5,    0,0,0,0,                     ''         , update=true, fmt=items.hexfmt }
items.raw      = { "DI_TEXT",         18,6,0,6,    0,0,0,0,                     ''         , update=true, fmt=items.rawfmt }
items.decfmt.fmt=items.dec
items.octfmt.fmt=items.oct
items.hexfmt.fmt=items.hex
items.rawfmt.fmt=items.raw

items.decrad   = { "DI_RADIOBUTTON",  5 ,3,0,3,    1,0,0,flags.DIF_GROUP,       ''         , item=items.dec }
items.octrad   = { "DI_RADIOBUTTON",  5 ,4,0,4,    0,0,0,0,                     ''         , item=items.oct }
items.hexrad   = { "DI_RADIOBUTTON",  5 ,5,0,5,    0,0,0,0,                     ''         , item=items.hex }
items.rawrad   = { "DI_RADIOBUTTON",  5 ,6,0,6,    0,0,0,0,                     ''         , item=items.raw }

items.dec1     = { "DI_TEXT",         16,3,0,3,    0,0,0,0,                     ':'        }
items.oct1     = { "DI_TEXT",         16,4,0,4,    0,0,0,0,                     ':'        }
items.hex1     = { "DI_TEXT",         16,5,0,5,    0,0,0,0,                     ':'        }
items.raw1     = { "DI_TEXT",         16,6,0,6,    0,0,0,0,                     ':'        }

items.statustxt= { "DI_TEXT",         5,7,0,7,     0,0,0,0,                     "Status:"  }
items.status   = { "DI_TEXT",         13,7,0,7,    0,0,0,0,                     'ok'       ,update=true}
items.btnCalculate = { "DI_BUTTON",    0,8,0,0,    0,0,0,{DIF_CENTERGROUP=1,DIF_DEFAULTBUTTON=1}, "Calculate (Enter)", action = act_calculate }
items.btnInsert  = { "DI_BUTTON",      0,8,0,0,    0,0,0,"DIF_CENTERGROUP",     "Insert (Ins)", action = act_insert }
items.btnCopy    = { "DI_BUTTON",      0,8,0,0,    0,0,0,"DIF_CENTERGROUP",     "Copy   (F5)",  action = act_copy }

active_item = items.dec
local keys={ Ins=items.btnInsert.id,
             F5 =items.btnCopy.id,
             Enter=items.btnCalculate.id,
             F1 = showHelp }

local function reset()
    items.dec[10]=''
    items.oct[10]=''
    items.hex[10]=''
    items.raw[10]=''
    items.status[10]=nil
    compiled  = nil
    raw_result= nil
    result    = 0
end

local function err_handler()
    reset()
    return false
end

local function format(item, r)
    local res_type=type(r)
    if res_type=='number' then
        item[10]=string.format(item.fmt[10],r)
    else
        item[10]=tostring(r)
    end
end

local function compile()
    local str=items.calc[10]
    if str:match('^%s-$') then
        compiled = loadstring( ' return 0 ' )
    else
        compiled = loadstring( str:find('^%s-return') and str or 'return '..str )
    end

    if compiled then
        setfenv(compiled, environ)
    else
        items.status[10]='Error: compile'
    end
end

local function call()
    raw_result=compiled()
    if not raw_result then
        items.status[10]='Error: call'
    elseif type(raw_result)=='function' then
        items.status[10]='Error: subcall'
        raw_result = raw_result()
    end
end

local function form()
    items.status[10]='Error: format'
    format(items.raw, raw_result)
    result = tonumber( raw_result )
    result=result or ''
    format(items.dec, result)
    format(items.oct, result)
    format(items.hex, result)
    items.status[10]='ok'
end
local chain={reset, compile, call, form}

local function dlg_handler(handle,msg,p1,p2)
    if msg==flags.DN_INITDIALOG or msg==flags.DN_EDITCHANGE then
        local cur_item=items[p1+1]
        cur_item[10] = far.GetDlgItem(handle,p1,nil)[10]
        if cur_item.fmt then
            if not pcall(form) then cur_item.fmt[10]='' end
            far.SetDlgItem(handle, cur_item.fmt.id, cur_item.fmt)
        else
            for k,v in ipairs(chain) do
                xpcall(v,err_handler)
                if items.status[10] then break end
            end
            for _, v in pairs(items) do
                if v.update then far.SetDlgItem(handle, v.id, v) end
            end
        end
    elseif msg==flags.DN_CONTROLINPUT or msg==flags.DN_INPUT then
        if p2.EventType==flags.KEY_EVENT then
            local f=keys[far.FarInputRecordToName(p2)]
            if f then
                if type(f)=='function' then
                    return f()
                else
                    far.SendDlgMessage(handle,flags.DM_CLOSE,f)
                end
            end
        end
    elseif msg==flags.DN_BTNCLICK then
        if items[p1+1].item then active_item=items[p1+1].item end
    elseif msg==flags.DN_CLOSE and p1>=0 then
        local btn=items[p1+1]
        if btn.action then return btn.action(handle) end
    end
end

local Guid = win.Uuid("e7588240-0523-4aa5-8a31-ee829e20cd26")
local calculator = function(t)
    loadUserFunctions()
    items.calc[10] = table.concat(t or {}) or ''
    arguments=t
    far.Dialog( Guid,2,5,77,14, nil, items, 0, dlg_handler )
end

calculator(...)
