context.config.register{key='flalias', path='fl_scripts', name='alias'}
local config = ctxdata.config

local disable_output = { KMFLAGS_DISABLEOUTPUT = 1 }

local function run_alias()
    local cmdline=panel.GetCmdLine(-1)
    local alias=config.flalias[cmdline]
    if not alias then return end
    panel.SetCmdLine(-1, alias)
    return far.MacroPost ("Enter", disable_output)
end

run_alias()
