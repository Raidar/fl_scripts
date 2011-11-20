--local menu = require 'fl_scripts/utils/treemenu'
local menu = require 'fl_scripts/utils/wrapmenu'
local contacts_path = '.\\contacts.adr'

local flags={FMENU_WRAPMODE=1}
local function contacts()
    local addresses={ {Title='addresses', Bottom='left, right. space, enter',Flags=flags,use_search=true}, {}}
    local current_menu=addresses
    local current_item=nil
    local dummy='dummy'
    for line in io.lines(contacts_path) do
        if line:find('^#FOLDER$') then
            local sub = { {Flag=flags,use_search=true}, {}, up=current_menu }
            current_item = { sub=sub }
            table.insert(current_menu[2],current_item)
            current_menu = sub
        elseif line:find('^#CONTACT$') then
            current_item = { text=dummy }
            table.insert(current_menu[2],current_item)
        elseif line:find('^%-$') then
            current_menu=current_menu.up
            current_item=nil
        elseif line:find('^%s+NAME=') then
            local name=line:match('^%s+NAME=(.+)')
            current_item.Name=name
            if not current_menu[1].Title then
                local fname=string.format('%-60s >',name)
                current_item.text=fname
                current_menu[1].Title=name
            else
                current_item.text=name
            end
        elseif line:find('^%s+MAIL=') then
            local mail=line:match('^%s+MAIL=(.+)')
            current_item.Mail=mail
            current_item.text=string.format('%-29s ³ %-28s',current_item.Name,mail)
        end
    end

    local res = menu(addresses)
    if res then
        far.Message(string.format('"%s" <%s>',res.Name or '',res.Mail or ''))
    end
end

contacts()
