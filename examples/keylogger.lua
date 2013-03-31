local flags=far.Flags
local width=70

local items = {
    { "DI_DOUBLEBOX",    3,1, width+6 ,5,    0,0,0,0,  "Key logger" },
    { "DI_TEXT",         4,3,0,3,            0,0,0,0,  ''           }
}
local str=''
local function dlg_handler(handle,msg,p1,p2)
    if msg==flags.DN_CONTROLINPUT or msg==flags.DN_INPUT then
        if p2.EventType==flags.KEY_EVENT then
            local key=far.InputRecordToName(p2)
            str=(str..' '..key):sub(-width)
            far.SendDlgMessage(handle, flags.DM_SETTEXT, 2, str)

            if key=='Esc' then far.SendDlgMessage(handle, flags.DM_CLOSE) end
        end
    end
end

local Guid = win.Uuid("22b07e07-c09f-4a0a-864a-8523f3a1c5ce")
local function keylogger()
    far.Dialog( Guid,-1,-1, 2+width+8,7, nil, items, 0, dlg_handler )
end

keylogger()
