local clear_path = require 'fl_scripts/utils/clear_path'
local discs

local function buildDisksTable ()
    local t = {}

    local user = win.GetEnv('USER') or ''
    local home = win.GetEnv('HOME') or ''
    home = home or '/home/'..user
    local dpath=home..'/.wine/dosdevices'

    local out=io.popen('/usr/bin/find '..dpath..' -executable -and -type l -printf "%f %l\n"')
    local lines=out:read '*a'
    out:close()
    for line in lines:gmatch '[^\n]+\n' do
        local disc, path=line:match '(%S+)%s+(%S+)'
        if path:sub(1,1)=='.' then
            path=dpath..'/'..path
        end
        path=clear_path(path, '/')
        t[disc:lower()], t[disc:upper()]=path, path
    end

    return t
end

local function winereplacer (path)
    local wp = io.popen( 'winepath -u '..path )
    local newpath = wp:read ('*a')
--    far.Message( newpath:byte(78) )
    wp:close()
    return newpath:gsub('\010', ''):gsub('\\','/')
end

local function replacepath (path)
    return path:gsub('%a:', fl_scripts.wineDiscs):gsub('\\','/')
end

local pattern='%a:[\\/][\\/%w%._]*'
local function winepath ()
    if not fl_scripts.wineDiscs then
        fl_scripts.wineDiscs=buildDisksTable()
    end
    local cmdline=panel.GetCmdLine(-1)
    --panel.SetCmdLine(-1, cmdline:gsub(pattern, replacepath) )
    panel.SetCmdLine(-1, replacepath(cmdline) )
end

winepath()
