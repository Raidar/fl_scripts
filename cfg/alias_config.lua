local pluginDir = far.PluginStartupInfo().ModuleName:match(".+\\")
local scriptsDir = pluginDir..'scripts'

return {
    farhome = 'cd %farhome%',
    farlua = 'cd '..scriptsDir,
    ['~config'] = 'edit:'..scriptsDir..'/fl_scripts/usrcfg/alias_config.lua'
}
