-------------------------------------------------------------------------------
-- Jumps to the next/previous or first/last selected item on the active panel.
-- @param where can be 'next','prev','first','last'
local function selection_jump(where)
    local pinfo = panel.GetPanelInfo(nil,1)
    if pinfo.SelectedItemsNumber==0 then return end
    local selected = far.Flags.PPIF_SELECTED
    local itemsnumber,curitem,topitem = pinfo.ItemsNumber,pinfo.CurrentItem,pinfo.TopPanelItem
    local first,last,dir=nil,nil,nil
    local rect=pinfo.PanelRect
    local height=rect.bottom-rect.top-4
    local hheight=math.floor(height)/2
    if where=='next' then
        first=curitem+1
        last=itemsnumber
        dir=1
    elseif where=='prev' then
        first=curitem-1
        last=1
        dir=-1
    elseif where=='first' then
        first=1
        last=itemsnumber
        dir=1
    elseif where=='last' then
        first=itemsnumber
        last=1
        dir=-1
    end

    for i=first,last,dir do
        if bit64.band(panel.GetPanelItem(-1, 1, i).Flags, selected) ~= 0 then
            panel.RedrawPanel(nil,1,{CurrentItem=i, TopPanelItem=( i>=topitem and i<(topitem+height) and topitem or i>hheight and i-hheight or 0 ) })
            return
        end
    end
end

local call=(...)[1]
if call then selection_jump(call) end
