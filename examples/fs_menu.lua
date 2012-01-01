local menu = require 'fl_scripts/utils/wrapmenu'
--local menu = require 'fl_scripts/utils/treemenu'
local clear_path = require 'fl_scripts/utils/clear_path'

local flags={FMENU_WRAPMODE=1}

local function sort_items(item1,item2)
    if item1.path then
       if item2.path then
           return item1.text<item2.text
       else
           return true
       end
    else
       if item2.path then
           return false
       else
           return item1.text<item2.text
       end
    end
end

local function fs_menu_generator(item)
    if type(item.sub)=='table' then return end
    local path=item.path
    if not path then return end
    path=clear_path(path)
    local items={}
    item.sub={ {Title=path, Bottom='left, right, space, backspace, enter', Flags=flags, use_search=true }, items }
    far.RecursiveSearch(path, '*', function(v0, fullp)
        local v=v0.FileName
        if v~='.' then
            local fname=v:match('[^\\/]+$') or '<empty>'
            local new_subitem={ text=fname, full=fullp, file=fname }
            if v0.FileAttributes:find 'd' then
                new_subitem.path=fullp
                if v=='..' then
                    new_subitem.donotunwrap=true
                    new_subitem.donotcheck=true
                    new_subitem.sub=item.up or true
                else
                    new_subitem.sub=true
                end
            end
            table.insert(items,new_subitem)
        end
    end)
    table.insert(items, { text='..', fullp=path..'/../', path=path..'/../', donotunwrap=true, donotcheck=true, sub=item.up or true } )

    table.sort(items,sort_items)
end

local function fs_menu()
    local root={path=panel.GetPanelDirectory(nil, 1).Name}
    fs_menu_generator(root)
    if root.sub then
        local res, pos, mtable, checked  = menu(root.sub, nil, fs_menu_generator)
        if not res then return end
        local msg='selected: '..res.full..'\n'
        for k, v in pairs(checked or {}) do
            msg=msg..'checked: '..k.file..'\n'
        end
        far.Message(msg or 'nothing', 'Files', nil, 'l')
    end
end

fs_menu()