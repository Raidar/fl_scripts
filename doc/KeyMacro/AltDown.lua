local LF4Ed = "6F332978-08B8-4919-847A-EFBB6154C99A"

local function condition() return Plugin.Exist(LF4Ed) end

Macro {
  description="GoTo/selection up";
  area="Shell"; key="AltUp"; flags="Selection"; condition=condition;
  action=function()
    if Plugin.Menu(LF4Ed) then Keys("<") end
  end;
}

Macro {
  description="GoTo/Selection down";
  area="Shell"; key="AltDown"; flags="Selection"; condition=condition;
  action=function()
    if Plugin.Menu(LF4Ed) then Keys(">") end
  end;
}

Macro {
  description="GoTo/selection home";
  area="Shell"; key="AltHome"; flags="EmptyCommandLine Selection";
  condition=condition;
  action=function()
    if Plugin.Menu(LF4Ed) then Keys("^") end
  end;
}

Macro {
  description="GoTo/selection end";
  area="Shell"; key="AltEnd"; flags="EmptyCommandLine Selection";
  condition=condition;
  action=function()
    if Plugin.Menu(LF4Ed) then Keys("v") end
  end;
}
