local LF4Ed = "6F332978-08B8-4919-847A-EFBB6154C99A"

Macro {
  description="Lua Screens";
  area="Common"; key="F12";
  condition=function() return Plugin.Exist(LF4Ed) end;
  action=function()
    if Plugin.Menu(LF4Ed) then Keys("*") end
  end;
}

