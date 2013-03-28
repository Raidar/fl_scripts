local smenu=require"far2.searchmenu"
local F = far.Flags
local band, bor, bxor, bnot = bit64.band, bit64.bor, bit64.bxor, bit64.bnot
local kF2 = {BreakKey='F2'}
local bClose = {BreakKey='DELETE'}
local bGoto = {BreakKey='RIGHT'}
local bkeys = {kF2, bClose, bGoto, [kF2] = true, [bClose] = true, [bGoto] = true}
local mFlags = { Flags = {FMENU_WRAPMODE=1, FMENU_AUTOHIGHLIGHT=1},
                 Title='Screens',
                 Bottom='F2: save, del: close, right: setpath'}

local function restore_focus(item,active)
    if item~=active then
        local active_i = active and active.i or 1
        far.AdvControl('ACTL_SETCURRENTWINDOW',
                       active_i - (active_i > item.i and 1 or 0))
        far.AdvControl('ACTL_COMMIT')
    end
end

local function show_windows()
--    local editors=ctxdata and ctxdata.editor
    local windows={}
    local active
    local count = far.AdvControl('ACTL_GETWINDOWCOUNT')
    for i = 1, count do
        local wind=far.AdvControl('ACTL_GETWINDOWINFO',i)
        wind.Current = (band(wind.Flags, F.WIF_CURRENT) ~= 0)
        wind.Modified = (band(wind.Flags, F.WIF_MODIFIED) ~= 0)
        if wind.Current then active=wind end
        local wintype=wind.TypeName:sub(1,1)
        local title=wind.Name:match('[^\\/]+$')
--      local etype= wintype=='E' and ('[ %s ]'):format(editors[i]) or '        '
        wind.SearchText=title or 'none'
        wind.text=('%2i. %s %s %s%s'):format(i, wintype,
                                             wind.Modified and '*' or ' ',
                                             wind.Current and '>' or ' ',
                                             title or 'none')
        wind.i=i
        table.insert(windows,wind)
    end
    if not active then
        for i,w in ipairs(windows) do
            w.disable=true
        end
    end

    mFlags.SelectIndex = mFlags.SelectIndex or (active and active.i) or 1
    local item,i=smenu( mFlags, windows, bkeys )
    if not item then return end
    if item.text then
        mFlags.Pattern=''
        mFlags.SelectIndex=nil
        far.AdvControl('ACTL_SETCURRENTWINDOW',item.i)
        far.AdvControl('ACTL_COMMIT')
    elseif bkeys[item] then
        mFlags.SelectIndex=i
        local key=item
        item=windows[i]
        local typ=item.Type
        if key == bClose and (typ == F.WTYPE_VIEWER or typ == F.WTYPE_EDITOR) and not item.Modified then
            far.AdvControl('ACTL_SETCURRENTWINDOW',item.i)
            far.AdvControl('ACTL_COMMIT')
            if typ == F.WTYPE_EDITOR then
                editor.Quit(item.Id)
            else
                viewer.Quit(item.Id)
            end
            far.AdvControl('ACTL_COMMIT')
            restore_focus(item,active)
            mFlags.SelectIndex=mFlags.SelectIndex - (mFlags.SelectIndex==#windows and 1 or 0)
        elseif key == kF2 and typ == F.WTYPE_EDITOR and item.Modified then
            far.AdvControl('ACTL_SETCURRENTWINDOW',item.i)
            far.AdvControl('ACTL_COMMIT')
            editor.SaveFile(item.Id)
            far.AdvControl('ACTL_COMMIT')
        elseif key == bGoto and (typ == F.WTYPE_VIEWER or typ == F.WTYPE_EDITOR) then
            local spath=item.Name
            local sdirpath, sname=spath:match('^(.+)\\([^\\]+)$')
            panel.SetPanelDirectory(nil,1,sdirpath)
            local pinfo = panel.GetPanelInfo(nil,1)
            local rect=pinfo.PanelRect
            local hheight=math.floor(rect.bottom-rect.top-4)/2
            local topitem=pinfo.TopPanelItem
            for i = 1, pinfo.ItemsNumber do
                local item=panel.GetPanelItem(nil,1,i)
                if item.FileName==sname then
                    panel.RedrawPanel(nil, 1,
                                      { CurrentItem = i,
                                        TopPanelItem = ( i >= topitem and i < (topitem + hheight) and topitem or
                                                         i > hheight and i - hheight or 1 ) })
                    break
                end
            end
            if active.Type == F.WTYPE_PANELS then
                far.AdvControl('ACTL_COMMIT')
            end
        end
        return show_windows()
    end
end

show_windows()
