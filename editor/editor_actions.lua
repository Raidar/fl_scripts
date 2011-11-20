require 'fl_scripts.editor.template'
local flags = far.Flags

function ProcessEditorEvent(ev,par)
    if ev==flags.EE_READ then
        fl_scripts.templates_menu()
    end
end
