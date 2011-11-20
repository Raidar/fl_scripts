local function reload_macro()
    local res=far.MacroLoadAll()
    far.Message(res and 'ok' or 'Error reloading macros','Reload macros',nil,res and '' or 'w')
end

reload_macro()