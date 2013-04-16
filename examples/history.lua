local smenu=require"far2.searchmenu"

local mFlags={ Flags = {FMENU_WRAPMODE=1}, Title='', Bottom=nil, search_plain=true }
local F=far.Flags
local FarId = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

local function get_history(subfolder)
  local far_settings = assert(far.CreateSettings("far"))
  local far_items = far_settings:Enum(subfolder)
  far_settings:Free()

  local items = {}
  for _,v in ipairs(far_items) do
    if v.PluginId == FarId then -- filter out archive plugins' items
      table.insert(items, { text=v.Name, file=v.Name })
    end
  end

  mFlags.SelectIndex=#items
  return smenu(mFlags,items)
end

local function get_view_history()
  local far_settings = assert(far.CreateSettings("far"))
  local view_items = far_settings:Enum(F.FSSF_HISTORY_VIEW)
  local edit_items = far_settings:Enum(F.FSSF_HISTORY_EDIT)
  far_settings:Free()

  local items = {}

  for _,v in ipairs(view_items) do
    table.insert(items, { file=v.Name, text='Viewer│ '..v.Name, time=v.Time })
  end

  for _,v in ipairs(edit_items) do
    table.insert(items, { file=v.Name, text='Editor│ '..v.Name, time=v.Time })
  end

  table.sort(items, function(a,b) return a.time<b.time end)

  mFlags.SelectIndex=#items
  return smenu(mFlags,items)
end

local function commands_history()
  mFlags.Title='Commands history'
  local item,i=get_history(F.FSSF_HISTORY_CMD)
  if item and item.text then
    panel.SetCmdLine(nil,item.text)
  end
end

local function dirs_history()
  mFlags.Title='Folders history'
  local item,i=get_history(F.FSSF_HISTORY_FOLDER)
  if item and item.text then
    panel.SetPanelDirectory(nil,1,item.text)
  end
end

local function view_history()
  mFlags.Title='View history'
  local item,i=get_view_history()
  if item and item.text then
    if item.text:find("^Editor") then
      editor.Editor(item.file,nil,nil,nil,nil,nil,F.EF_NONMODAL)
    else
      viewer.Viewer(item.file,nil,nil,nil,nil,nil,F.EF_NONMODAL)
    end
  end
end

local call=(...)[1]
if call=='commands' then commands_history()
elseif call=='dirs' then dirs_history()
elseif call=='view' then view_history()
end
