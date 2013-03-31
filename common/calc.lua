local far2dialog=require 'far2.dialog'
local F=far.Flags
local IND_TYPE,IND_DATA = 1,10

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
  local path=far.PluginStartupInfo().ModuleDir..'scripts\\fl_scripts\\functions'
  local message='Loading:'
  for _,item in ipairs( far.GetDirList(path) ) do
    local fname=item.FileName
    if not item.FileAttributes:find 'd' and fname:sub(-4):lower()==".lua" then
      message=message..'\n'..fname:match('[^\\/]+$')
      local st=loadUserFunction(fname, functions)
      message=message..(st and ' ok' or ' fail')
    end
  end
  message=message..'\nLoaded:'
  for k, v in pairs(functions) do
    environ[k]=v
    message=message..'\n'..k..' -> '..tostring(v)
  end
  if verbose then far.Message(message) end
end

local function act_calculate(handle)
  local edt=items.calc
  edt[IND_DATA]=raw_result
  far.SetDlgItem(handle, edt.id, edt)
  return 0
end

local function act_copy()
  far.CopyToClipboard(active_item[IND_DATA])
  return 0
end

local function act_insert()
  if arguments.From=='dialog' then
    local id = far.SendDlgMessage(arguments.hDlg, "DM_GETFOCUS")
    local item = far.GetDlgItem(arguments.hDlg, id)
    if item[IND_TYPE]==F.DI_EDIT or
      item[IND_TYPE]==F.DI_FIXEDIT or
      item[IND_TYPE]==F.DI_COMBOBOX
    then
      far.SendDlgMessage(arguments.hDlg, "DM_SETTEXT", id, active_item[IND_DATA])
    end
  elseif arguments.From=='editor' then
    editor.InsertText(nil, active_item[IND_DATA])
  elseif arguments.From=='panels' then
    panel.SetCmdLine(nil, active_item[IND_DATA])
  end
end

items._        = { "DI_DOUBLEBOX",    3,1,72,8,    0,0,0,0,                     "Lua Calc" }
items.calc     = { 'DI_EDIT',         5,2,70,2,    0,'LuaCalc',0,F.DIF_HISTORY, ''}

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

items.decrad   = { "DI_RADIOBUTTON",  5 ,3,0,3,    1,0,0,F.DIF_GROUP,       ''         , item=items.dec }
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
  items.dec[IND_DATA]=''
  items.oct[IND_DATA]=''
  items.hex[IND_DATA]=''
  items.raw[IND_DATA]=''
  items.status[IND_DATA]=nil
  compiled  = nil
  raw_result= nil
  result    = 0
end

local function err_handler()
  reset()
  return false
end

local function format(item, r)
  if type(r)=='number' then
    item[IND_DATA]=string.format(item.fmt[IND_DATA],r)
  else
    item[IND_DATA]=tostring(r)
  end
end

local function compile()
  local str=items.calc[IND_DATA]
  if str:match('^%s*$') then
    compiled = loadstring( ' return 0 ' )
  else
    compiled = loadstring( str:find('^%s*return') and str or 'return '..str )
  end

  if compiled then
    setfenv(compiled, environ)
  else
    items.status[IND_DATA]='Error: compile'
  end
end

local function call()
  raw_result=compiled()
  if not raw_result then
    items.status[IND_DATA]='Error: call'
  elseif type(raw_result)=='function' then
    items.status[IND_DATA]='Error: subcall'
    raw_result = raw_result()
  end
end

local function form()
  items.status[IND_DATA]='Error: format'
  format(items.raw, raw_result)
  result = tonumber( raw_result )
  result=result or ''
  format(items.dec, result)
  format(items.oct, result)
  format(items.hex, result)
  items.status[IND_DATA]='ok'
end
local chain={reset, compile, call, form}

local function dlg_handler(handle,msg,p1,p2)
  if msg==F.DN_INITDIALOG or msg==F.DN_EDITCHANGE then
    local cur_item=items[p1]
    cur_item[IND_DATA] = far.GetDlgItem(handle,p1,nil)[IND_DATA]
    if cur_item.fmt then
      if not pcall(form) then cur_item.fmt[IND_DATA]='' end
      far.SetDlgItem(handle, cur_item.fmt.id, cur_item.fmt)
    else
      for k,v in ipairs(chain) do
        xpcall(v,err_handler)
        if items.status[IND_DATA] then break end
      end
      for _, v in pairs(items) do
        if v.update then far.SetDlgItem(handle, v.id, v) end
      end
    end
  elseif msg==F.DN_CONTROLINPUT or msg==F.DN_INPUT then
    if p2.EventType==F.KEY_EVENT then
      local f=keys[far.InputRecordToName(p2)]
      if f then
        if type(f)=='function' then
          return f()
        else
          far.SendDlgMessage(handle,F.DM_CLOSE,f)
        end
      end
    end
  elseif msg==F.DN_BTNCLICK then
    if items[p1].item then active_item=items[p1].item end
  elseif msg==F.DN_CLOSE and p1>=1 then
    local btn=items[p1]
    if btn.action then return btn.action(handle) end
  end
end

local Guid = win.Uuid("e7588240-0523-4aa5-8a31-ee829e20cd26")
local calculator = function(t)
  loadUserFunctions()
  items.calc[IND_DATA] = t and table.concat(t) or ''
  arguments=t
  far.Dialog( Guid,-1,-1,76,10, nil, items, 0, dlg_handler )
end

calculator(...)
