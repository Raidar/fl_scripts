--[[ fl_scripts ]]--

local scriptspath='scripts/fl_scripts/'
rawset(_G, 'fl_scripts', {})

if not rawget(_G, 'context') then
    far.Message("'context' package is not installed.\nFailed to load fl_scripts.", 'Error', nil, 'w')
    return
end

-- [==[
context.config.register{key='flhotkeys', path='fl_scripts', name='hotkeys'}
local hotkeys = ctxdata.config.flhotkeys
setmetatable(hotkeys, {__index=function() return '' end})

--------------------------------------------------------------------------------
local scripts = {
    editor_actions  = { file='editor_actions',    area='e'        },

    comment         = { file="comment",           area='e'        },
    nav             = { file="nav",               area='e'        },
    sections        = { file="sections",          area='e'        },
    multiclip       = { file='multiclip',         area='e'        },

    copysymbol      = { file='copysymbol',        area='e'        },
    smartkeys       = { file='smartkeys',         area='e'        },
    block           = { file='block',             area='e'        },
    blockindent     = { file='blockindent',       area='e'        },
    select          = { file='select',            area='e'        },

    seljump         = { file='selection_jump',    area='p'        },
    alias           = { file='alias',             area='p'        },
    winepath        = { file='winepath',          area='p'        },
    panelfilter     = { file='panelfilter',       area='p'        },
    reload_macro    = { file='reload_macro',      area='evp'      },
    calc            = { file="calc",              area='evpd'     },
    screens         = { file="screens",           area='evp'      },
}
fl_scripts.scripts=scripts

for k,v in pairs(scripts) do
   local area=v.area
   local folder= area=='e' and 'editor/' or area=='p' and 'panels/' or area:match '^evp' and 'common/'
   v.file=scriptspath..folder..v.file
end

----------------------------------------
-- [=[
local entries={
    { name="Comments",       key=nil, script=scripts.comment },
    { name="Navigation",     key=nil, script=scripts.nav },
    { name="Lua calc                            &#", key=nil, script=scripts.calc },
    { name="Screens                             &*", key=nil, script=scripts.screens },

    { name='Sections', key=hotkeys.sections, script=scripts.sections  },
    { name='Multiclip', key=hotkeys.multiclip, script=scripts.multiclip  },

    { name='Copy up sumbol',   hide=true, key=hotkeys.copyupsymbol, script=scripts.copysymbol, argument='copysymbol()' },
    { name='Copy down sumbol', hide=true, key=hotkeys.copydownsymbol, script=scripts.copysymbol, argument='copysymbol(true)' },

    { name='SmartHome',  hide=true, key=hotkeys.smarthome, script=scripts.smartkeys, argument='smarthome()' },
    { name='SmartTab',   hide=true, key=hotkeys.smarttab, script=scripts.smartkeys, argument='smarttab()' },

    { name='AutoComment',    hide=true, key=hotkeys.autocomment, script=scripts.comment, argument='autocomment()' },
    { name='AutoUnComment',  hide=true, key=hotkeys.autouncomment, script=scripts.comment, argument='autouncomment()' },

    { name='Jump to block begin', hide=true, key=hotkeys.jumptoblockbegin, script=scripts.block, argument='jumptoblockbegin()' },
    { name='Jump to block end',   hide=true, key=hotkeys.jumptoblockend, script=scripts.block, argument='jumptoblockend()' },

    { name='Indent right',        hide=true, key=hotkeys.indentright, script=scripts.blockindent, argument='indentright()' },
    { name='Indent left',         hide=true, key=hotkeys.indentleft, script=scripts.blockindent, argument='indentleft()' },

    { name='Select stream (begin)', hide=true, key=hotkeys.select_stream, script=scripts.select, argument='exselect()' },
    { name='Select column (begin)', hide=true, key=hotkeys.select_column, script=scripts.select, argument='exselect(true)' },

    { name='Navigate',              hide=true, key=hotkeys.navigate, script=scripts.nav, argument='navigate()' },
    { name='Navigate current',      hide=true, key=hotkeys.navigate_current, script=scripts.nav, argument='navigate()' },
    { name='Find associated file',  hide=true, key=hotkeys.source, script=scripts.nav, argument='source()' },

    { name='Jump to the next selected item.     &>', key=nil, script=scripts.seljump, argument='selection_jump("next")' },
    { name='Jump to the previous selected item. &<', key=nil, script=scripts.seljump, argument='selection_jump("prev")' },
    { name='Jump to the first selected item.    &^', key=nil, script=scripts.seljump, argument='selection_jump("first")' },
    { name='Jump to the last selected item.     &v', key=nil, script=scripts.seljump, argument='selection_jump("last")' },
    { name='Panel Filter                        &:', key=nil, script=scripts.panelfilter, argument="filter()" },
    { name='Panel Filter: delete                &;', key=nil, script=scripts.panelfilter, argument="delete_filter()" },
    { name='Alias                               &@', key=nil, script=scripts.alias },
--  { name='Winepath                            &w', key=nil, script=scripts.winepath },

    { name='Reload macros', key=nil, script=scripts.reload_macro },
}
fl_scripts.entries=entries

----------------------------------------
AddToMenu('evp',":sep:fl scripts")
for i, v in ipairs(entries) do
    AddToMenu(v.script.area, not v.hide and v.name, v.key, v.script.file, v.argument)
end
--]=]
--]==]

----------------------------------------
AddCommand('calc', scripts.calc.file)
AddCommand('filter', scripts.panelfilter.file, "filter()")
AddCommand("dir", scriptspath.."examples/fs_menu")

MakeResident(scripts.editor_actions.file)
--------------------------------------------------------------------------------
