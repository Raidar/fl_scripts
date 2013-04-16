
local FK = far.Keys
---------------------------------------------------------------------
-- Sets position to the first nonspace character
local function smarthome()
    local p = editor.GetInfo().CurPos
    local p_S = editor.GetString(nil,nil,2):find('%S') or 1
    editor.SetPosition(nil,nil,(p==1 or p>p_S) and p_S or 1,nil,nil,1)
    editor.Redraw()
end

--------------------------------------------------------------------
--
local function find_nearest_space_right(line,pos,down)
   local newpos=nil
   for i=1,10 do
       if down and line<down then return nil end
       line = line + (down and 1 or -1)
       local str=editor.GetString(nil,line,2)
       if str and str~='' then
           local pp,spos=str:find('%s%s+%S',pos)
           if spos then
               if not newpos or newpos>spos then
                   return spos
               end
           end
       end
   end
   return newpos and (newpos-1) or nil
end

-----------------------------------------------------------------------
----
--function smartbs()
--    local einfo = editor.GetInfo()
--    local l,p = einfo.CurLine, einfo.CurPos
--    local str = editor.GetString(nil,-1,1).StringText
--    str=str:sub(1,p)
--    if not str:sub(p-1,p):find('^%s%s+$') then editor.ProcessKey(FK.KEY_BS) end
--    local spaces=str:match('%s+$')
--    local nspaces=#spaces
--    local n=nil
--    for i=1,10 do
--        line=line-1
--        local str=editor.GetString(nil,line,2):sub(p-nspaces,p)
--
--    end
--
----    far.Message(n)
----    einfo.CurPos = einfo.CurPos-n
--    --editor.SetPosition(nil,einfo)
----    local n=1
----    for i=1,n do editor.ProcessKey(FK.KEY_BS) end
--    editor.Redraw()
--end

---------------------------------------------------------------------
--
local function smarttab()
    local einfo = editor.GetInfo()
    local l,p = einfo.CurLine,einfo.CurPos
    local spos = find_nearest_space_right(l,p)  -- einfo.TotalLines
    editor.SetPosition(nil,einfo)
    local tab=spos and (spos-p) or einfo.TabSize
    editor.InsertText( nil,string.format('%'..tostring( tab )..'s',''))
    editor.Redraw()
end

local call=(...)[1]
if call=='smarthome' then smarthome()
elseif call=='smarttab' then smarttab()
end
