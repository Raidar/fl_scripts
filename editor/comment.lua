context.config.register{key='flcomments', inherit=true, path='fl_scripts', name='comment'}

local F = far.Flags
local histControl = editor.UndoRedo
local startBlock, stopBlock = F.EUR_BEGIN, F.EUR_END

local EditorDeleteChar=editor.DeleteChar
local EditorGetInfo=editor.GetInfo
local EditorGetString=editor.GetString
local EditorInsertText=editor.InsertText
local EditorRedraw=editor.Redraw
local EditorSelect=editor.Select
local EditorSetPosition=editor.SetPosition

local editors=ctxdata.editors
local config=ctxdata.config

local resetselection=false

local farselection = require 'fl_scripts/utils/block_iterator'
local cfg=nil

local editinfo = nil
local comment,uncomment={},{}

local function init()
    cfg=editors.current.flcomments or config.flcomments.default
    if not cfg then return false end
    editinfo = EditorGetInfo()
    return true
end

-------------------------------------------------------------------------------
-- comment the stream block line or unselected line
-- it adds 'line' comment at the begin of the string
function comment.line(line,str)
    local p2,p1=0
    if cfg.skipSpaces then
        p1,p2=str.StringText:find('^%s*')
    end

    EditorSetPosition(nil,{CurPos=p2})
    EditorInsertText(nil,cfg.line)
end

-------------------------------------------------------------------------------
-- comment unselected line with left and right comment
function comment.line_lr(line,str)
    EditorSetPosition(nil,{CurPos=0})
    EditorInsertText(nil,cfg.left)
    EditorSetPosition(nil,{CurPos=str.StringLength+#cfg.left})
    EditorInsertText(nil,cfg.right)
end

-------------------------------------------------------------------------------
-- comment the column block line
-- it adds 'left' and 'right' on the left and right borders of the selection
function comment.block(line,str)
    local p1,p2=str.SelStart,str.SelEnd
    EditorSetPosition(nil,{CurPos=p1})
    EditorInsertText(nil,cfg.left)
    EditorSetPosition(nil,{CurPos=p2+#cfg.left})
    EditorInsertText(nil,cfg.right)
end

-------------------------------------------------------------------------------
-- comment the whole stream block with left/right comment
-- call in case of absense of line comment or when stream selection starts not from the linestart
function comment.all(line,str,displace,force)
    local displ=0
    if line==editinfo.BlockStartLine and not force then
        EditorSetPosition(nil,{CurPos=str.SelStart})
        EditorInsertText(nil,cfg.left)
        displ=#cfg.left
    end
    local send=str.SelEnd
    if send~=-1 or force then
        EditorSetPosition(nil,{CurPos=(send~=-1 and str.SelEnd or str.StringLength) + (displace or displ) })
        EditorInsertText(nil,cfg.right)
        return
    end
    return true,line,str,displ  --is meaningful when selection ends at the end of the screen, i. e. send==-1 and comment.all cann't determine the block end on a single call
end

-------------------------------------------------------------------------------
-- uncomment the stream block line or unselected line
-- it tries to delete first occurance of the 'line' comment
function uncomment.line (line, str)
    local lpos = str.StringText:find(cfg.line,0,true)
    if not lpos then return end
    EditorSetPosition(nil, {CurPos = lpos - 1})
    for i = 1, #cfg.line do EditorDeleteChar() end
end

-------------------------------------------------------------------------------
-- uncomment unselected line with left and right comment
function uncomment.line_lr (line, str)
    EditorSetPosition(nil, {CurPos = 0})
    for i = 1, #cfg.left do EditorDeleteChar() end
    EditorSetPosition(nil, {CurPos = str.StringLength - #cfg.left - #cfg.right})
    for i = 1, #cfg.right do EditorDeleteChar() end
end

-------------------------------------------------------------------------------
-- uncomment the column block line
-- it tries to delete 'left' and 'right' comments on whole the selected lines
function uncomment.block (line, str)
    local strtext = str.StringText
    local c11, c12, c21, c22 = strtext:find(cfg.left, 1, true), strtext:find(cfg.right, 1, true)
    if c11 and c12 and c11 < c12 then
        EditorSetPosition(nil, {CurPos = c11 - 1})
        for i = 1, #cfg.left do EditorDeleteChar() end
        EditorSetPosition(nil, {CurPos = c12 - 1 - #cfg.left})
        for i = 1, #cfg.right do EditorDeleteChar() end
    end
end

-------------------------------------------------------------------------------
-- uncomment the whole stream block
-- call in case of absense of line comment
function uncomment.all (line, str, displace, force)
    local displ = 0
    local strtext = str.StringText
    if line == editinfo.BlockStartLine and not force then
        local c11 = strtext:find(cfg.left, 1, true)
        if not c11 then return end
        EditorSetPosition(nil, {CurPos=c11-1})
        displ = #cfg.left
        for i = 1, displ do EditorDeleteChar() end
    end
    if str.SelEnd ~= -1 or force then
        local c21 = strtext:find(cfg.right,1,true)
        if not c21 then return end
        EditorSetPosition(nil, {CurPos=c21-1-(displace or displ)})
        for i = 1, #cfg.right do EditorDeleteChar() end
        return
    end
    return true, line, str, displ   -- same meaning as in comment.all
end

-------------------------------------------------------------------------------
-- choose function to (un)comment and apply it to every line of selection
local function do_the_job (ftable)
    if not init() then return end
    local blocktype = editinfo.BlockType
    local commenter = ftable.line
    local blk_start_str = blocktype ~= F.BTYPE_NONE and EditorGetString(nil, editinfo.BlockStartLine, 0) or nil
    if cfg.left and cfg.right then
        if blocktype == F.BTYPE_COLUMN then
            commenter = ftable.block
        elseif blocktype == F.BTYPE_NONE and not cfg.line then
            commenter = ftable.line_lr
        elseif not cfg.line or (blocktype == F.BTYPE_STREAM and blk_start_str.SelStart ~= 0) then
            commenter = ftable.all
        end
    elseif not cfg.line then
        return
    end

    local status, line, laststr, displ = false
    histControl(nil, startBlock)
    for i, str in farselection(true) do
        status, line, laststr, displ = commenter(i, str)
    end
    if status then
        EditorSetPosition(nil,{CurLine=line})
        commenter(line,laststr,displ,true)
    end
    if resetselection then EditorSelect(nil, 'BTYPE_NONE') end
    EditorSetPosition(nil, editinfo)
    histControl(nil, stopBlock)
    EditorRedraw()
    cfg=nil
end

local function autocomment ()   do_the_job(comment)   end
local function autouncomment () do_the_job(uncomment) end

-------------------------------------------------------------------------------
-- Call 'comment' menu
local function comment_menu (call)
    if call=='comment' then autocomment(); return; end
    if call=='uncomment' then autouncomment(); return; end

    local menu = { {text='&Auto comment',   call=autocomment      },
                   { text='&Uncomment',     call=autouncomment    } }

    local key, item = far.Menu ({
      Flags = { FMENU_WRAPMODE=1, FMENU_AUTOHIGHLIGHT=1 },
      Title = 'Comments',
    }, menu)
    if item then menu[item].call() end
end

comment_menu((...)[1])
