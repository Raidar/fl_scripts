--[[ Main data ]]--

----------------------------------------
--[[ description:
  -- File sections.
  -- Разделы файла.
--]]
--------------------------------------------------------------------------------
local c_fun = '[^e%s][%w_:]-%s-[%*%[%]&]-%s+[%w_:]+%s-%([^%);]-%))[^;]-$'
local ini_sec = '^%[(.+)%]'

----------------------------------------
local types = {

  -- 1. text

      -- 1.1. plain text --

      -- 1.1. plain text

          -- 1.1.-. default text
  txt       = { pattern = { '^%s-[%d\.\)]+%s-.+' } },

              -- rare
              -- test

          -- 1.1.-. formed text
              -- Message:
              -- Others:

      -- 1.2. rich text

          -- 1.2.1. config text
  ini       = { pattern = { ini_sec } },

              -- FAR Manager & plugins:
              -- System config:
              -- Windows config:

          -- 1.2.2. data define
              -- Resources:

              -- Subtitles:
    sub_assa  = { pattern = { ini_sec } },

                  -- rare
              -- Script data:
                  -- FAR Manager & plugins:
                  -- rare
              -- Network data:

          -- 1.2.3. markup text
  --rtf       =
  tex       = { pattern = {
                  '\\part{[^}]-}',
                  '\\chapter{[^}]-}',
                  '\\section{[^}]-}',
                  '\\subsection{[^}]-}',
                  '\\paragraph{[^}]-}',
                  '\\begin{document}'
              } },

              -- rare
              -- FAR Manager & plugins:
  far_hlf   = { pattern = {'^@.+'} },
                  -- rare
              -- SGML subsets:
                  -- rare
              -- XML main:
              -- XML book:
              -- XML others:
                  -- rare
              -- SGML others:
                  -- rare
              -- Colorer-take5:

      -- 1.3. source

          -- 1.3.1. language source

              -- 1.3.1.1. frequently used language

  c         = { pattern = {
                  '^%s-(static%s+'..c_fun,
                  '^%s-(const%s+'..c_fun,
                  '^%s-(inline%s+'..c_fun,
                  '^%s-('..c_fun,
                  '^([%w_]+::~-[%w_]+%s-%([^%)]-%))',
                  '^%s-(friend%s+%w+%s+%w+)',
                  '^%s-(class%s+%w+)',
                  '^%s-(namespace%s+%w+)',
                  '^%s-(typedef%s+%w+)'
                } },

  fortran   = { pattern = { 'SUBROUTINE%s.+', 'ENTRY%s.+' } },

  python    = { pattern = {
                  'class%s+[%w_]+',
                  '(def%s+[%w_]+%s-)%([^%)]-'
                } },

                  -- rare
                  -- Assembler other:
                  -- HDL:
                  -- ML:
                  -- Prolog:
                  -- Lexers:
                  -- Java somes:

              -- 1.3.1.2. database language --
                  -- rare

              -- 1.3.1.-. .NET support language

              -- 1.3.1.3. network language
                  -- 1.3.1.3.-. network script
                  -- 1.3.1.3.-. server pages

          -- 1.3.2. script language --
                  -- Lua:
  lua       = { pattern = {
                  'local%s+function%s+[%w_%.:]+%s-%([^%)]-%)',
                  'function%s+[%w_%.:]+%s-%([^%)]-%)',
                  'local%s+[%w_%.:]+%s-=%s-function%s-%([^%)]-%)',
                  '[%w_%.:%[%]]+%s-=%s-function%s-%([^%)]-%)'
                } },

              -- 1.3.2.1. batch/shell --
  shell     = { pattern = {'^%s-[^%(]+%s-%(%s-%)'} },

  fish      = { pattern = {'^%s-function%s+(%S+)'} },

                  -- rare

              -- 1.3.2.-. makefile
  makefile  = { pattern = {'^[^#\t][^:]+:[^=]'} },

                  -- rare

              -- 1.3.2.-. install script

  -- 2. packed

      -- 2.1. exec --

      -- 2.2. store --

          -- 2.2.1. arch --

          -- 2.2.2. disk --

      -- 2.3. media

          -- 2.3.1. image --

          -- 2.3.2. audio --

          -- 2.3.3. video --

  -- 3. mixed

      -- 3.1. doc
              -- Composed help:

      -- 3.2. font --

      -- 3.3. others

} --- types

return types
--------------------------------------------------------------------------------
