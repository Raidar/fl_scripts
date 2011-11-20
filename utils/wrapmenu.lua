local treemenu=require'fl_scripts/utils/treemenu'
local unwrap_key={BreakKey='RIGHT'}
local wrap_key={BreakKey='LEFT'}
local sel_key={BreakKey='SPACE'}

local function has_value(tbl,value)
    for _,v in ipairs(tbl) do
        if v==value then return true end
    end
end

local function unwrap_item(items,item,level)
    table.insert(items,item)
    if item.sub and not item.donotunwrap then
        if item.unwrap then
            item.text=item.text:gsub('^[%s+-]*',string.format('%'..(level)..'s- ',''))
            for k,v in ipairs(item.sub[2]) do
               v.in_submenu=item
               unwrap_item(items,v,level+2)
            end
        else
            item.text=item.text:gsub('^[%s+-]*',string.format('%'..(level)..'s+ ',''))
        end
    else
        item.text=item.text:gsub('^%s*',string.format('%'..(level+2)..'s',''))
    end
end

local function do_wrap(mtable)
    local res_menu={}
    for k,v in pairs(mtable) do
        res_menu[k]=v
    end
    res_menu[2]={}

    for _,v in ipairs(mtable[2]) do
        if type(v.sub)=='table' then
            v.sub.upmenu=mtable
        end
        unwrap_item(res_menu[2],v,0)
    end

    return res_menu
end

local function check(item, ctable)
    if not item or item.donotcheck then return end
    if type(item.sub)=='table' then
        item.unwrap=true
        for _,v in ipairs(item.sub[2]) do
           check(v, ctable)
        end
    else
        item.checked=not item.checked
        ctable[item]=item.checked or nil
    end
end

local function wrapmenu( mtable, caller, sub_generator, global_upmenu, item_to_sel )
    if not global_upmenu then global_upmenu=mtable end
    global_upmenu.checked=global_upmenu.checked or {}
    local mtable1=do_wrap(mtable)
    if mtable1[3] then
        if not has_value(mtable1[3],unwrap_key) then
            table.insert(mtable1[3],unwrap_key)
            table.insert(mtable1[3],wrap_key)
            table.insert(mtable1[3],sel_key)
        end
    else
        mtable1[3]={unwrap_key,wrap_key,sel_key}
    end

    if item_to_sel then
        for i,v in ipairs(mtable1[2]) do
            if v==item_to_sel then
                mtable1[1].SelectIndex=i
                break
            end
        end
    end
    local item,position=treemenu( mtable1, wrapmenu, sub_generator, mtable )
    local cur_item=mtable1[2][position]
    if item==unwrap_key then
        if sub_generator and cur_item.sub then
            sub_generator( cur_item )
        end
        if cur_item.sub and not cur_item.donotunwrap then
            cur_item.unwrap=true
        end
        mtable1=nil
        return wrapmenu( mtable, wrapmenu, sub_generator, global_upmenu, cur_item )
    elseif item==wrap_key then
        if cur_item.sub and cur_item.unwrap then
            cur_item.unwrap=false
        elseif cur_item.in_submenu and cur_item.in_submenu.unwrap then
            cur_item=cur_item.in_submenu
            cur_item.unwrap=false
        end
        mtable1=nil
        return wrapmenu( mtable, wrapmenu, sub_generator, global_upmenu, cur_item )
    elseif item==sel_key then
        check(cur_item, global_upmenu.checked)
        mtable1=nil
        return wrapmenu( mtable, wrapmenu, sub_generator, global_upmenu, cur_item )
    else
        return item, position, mtable1, global_upmenu.checked
    end
end

return wrapmenu
