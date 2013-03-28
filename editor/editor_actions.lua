require 'fl_scripts.editor.template'
local F = far.Flags

function ProcessEditorEvent (id, ev, par)
    if ev == F.EE_READ then
        fl_scripts.templates_menu()
    end
end
