local smenu=require"far2.searchmenu"
local farselection=require'fl_scripts/utils/block_iterator'

local mFlags={ Flags = {FMENU_WRAPMODE=1,FMENU_AUTOHIGHLIGHT=1}, Title='multiclip', Bottom='del(this),c+del(all),ins(replace),right/c-right(new),s/c+ins(clip)'}

if not rawget(fl_scripts,'my_memory') then
   rawset(fl_scripts, 'my_memory', {})
end
local my_memory=fl_scripts.my_memory
my_memory.multiclip=my_memory.multiclip or {}
local clips=my_memory.multiclip

local kDel={BreakKey='DELETE'}
local kCDel={BreakKey='C+DELETE'}
local kIns={BreakKey='INSERT'}
local kCIns={BreakKey='C+INSERT'}
local kSIns={BreakKey='S+INSERT'}
local kRight={BreakKey='RIGHT'}
local kCRight={BreakKey='C+RIGHT'}
local bkeys={kDel,kCDel,kIns,kSIns,kCIns,kRight,kCRight,[kDel]=true,[kCDel]=true,[kIns]=true,[kSIns]=true,[kCIns]=true,[kRight]=true,[kCRight]=true}

local function fill(item)
    local data={}
    local eol
    for _,str in farselection(true) do
        local st,en
        if str.SelStart>=0 then
            st,en=str.SelStart+1 or 1, str.SelEnd>=0 and str.SelEnd or -1
        else
            st,en=1,-1
        end
        table.insert(data, str.StringText:sub(st, en))
    end
    item.data=table.concat(data,'\r')
    item.size=#item.data
    return item
end

local function multiclip()
    for i,v in pairs(clips) do
        v.text=string.format('%2s ³ %4i ³ %s',i,v.size,v.data:sub(1,40))
    end
    local item,i=smenu(mFlags,clips,bkeys)
    if not item then return end
    if item.text then
        editor.InsertText(nil,item.data)
        mFlags.SelectIndex=nil
    elseif bkeys[item] then
        if item==kCDel then
            my_memory.multiclip={}
            clips=my_memory.multiclip
            mFlags.SelectIndex=nil
        elseif item==kDel then
            table.remove(clips,i)
            mFlags.SelectIndex=i>#clips and i-1 or i
        elseif item==kRight then
            table.insert(clips,fill({}))
            mFlags.SelectIndex=#clips
        elseif item==kCRight then
            for _,str in farselection(true) do
                local st,en
                if str.SelStart>=0 then
                    st,en=str.SelStart+1 or 1, str.SelEnd>=0 and str.SelEnd or -1
                else
                    st,en=1,-1
                end
                local data=str.StringText:sub(st,en)
                table.insert(clips,{data=data, size=#data})
            end
        elseif item==kIns and #clips~=0 then
            fill(clips[i])
        elseif item==kCIns and #clips~=0 then
            far.CopyToClipboard(clips[i].data)
        elseif item==kSIns then
            local data=far.PasteFromClipboard()
            clips[i].data=data
            clips[i].size=#data
        end
        return multiclip()
    end
end

multiclip()
