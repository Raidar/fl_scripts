local smenu=require"far2.searchmenu"
local back_key={BreakKey='BACK'}

local function has_value(tbl,value)
    for _,v in ipairs(tbl) do
        if v==value then return true end
    end
end

-------------------------------------------------------------------------------
-- every item contains normal menu parameters(flags,items,bkeys)
-- function makes menu
-- @arg { [1]=flags, [2]=items, [3]=bkeys}
-- item can contain 'sub' field --- it means that this item is submenu
-- sub field is again table: { [1]=flags, [2]=items, [3]=bkeys}
local function treemenu( mtable, caller, sub_generator, global_upmenu )
    if mtable.upmenu and not mtable[1].freeze_tree then
        if mtable[3] then
            if not has_value(mtable[3],back_key) then
                table.insert(mtable[3],back_key)
            end
        else
            mtable[3]={back_key}
        end
    end
    local item,position=nil,nil
    if mtable[1].use_search then
        item,position=smenu( unpack(mtable) )
    else
        item,position=far.Menu( unpack(mtable) )
    end
    if item then
        if not mtable[1].freeze_tree then
            local upmenu=mtable.upmenu
            if item==back_key and upmenu then
                upmenu[1].SelectIndex=mtable.position
                upmenu[1].Pattern=nil
                return (caller or treemenu)( upmenu, caller, sub_generator, global_upmenu )
            end

            if sub_generator then
                sub_generator( item )
            end
            local sub=item.sub
            if sub then
                if not sub.upmenu then
                    sub.upmenu=global_upmenu or mtable
                end
                if not sub.position then
                    sub.position=position
                end
                return (caller or treemenu)( sub, caller, sub_generator, global_upmenu )
            else
                return item,position,mtable
            end
        else
            return item,position,mtable
        end
    end
end

return treemenu
