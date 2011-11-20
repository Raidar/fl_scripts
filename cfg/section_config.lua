local types={}
local c_fun = '[^e%s][%w_:]-%s-[%*%[%]&]-%s+[%w_:]+%s-%([^%);]-%))[^;]-$'
types.c= { pattern={  '^%s-(static%s+'..c_fun,
                      '^%s-(const%s+'..c_fun,
                      '^%s-(inline%s+'..c_fun,
                      '^%s-('..c_fun,
                      '^([%w_]+::~-[%w_]+%s-%([^%)]-%))',
                      '^%s-(friend%s+%w+%s+%w+)',
                      '^%s-(class%s+%w+)',
                      '^%s-(namespace%s+%w+)',
                      '^%s-(typedef%s+%w+)'
                      } }

types.fortran= { pattern={ 'SUBROUTINE%s.+', 'ENTRY%s.+' } }

types.lua= { pattern={'local%s+function%s+[%w_%.:]+%s-%([^%)]-%)',
                       'function%s+[%w_%.:]+%s-%([^%)]-%)',
                       'local%s+[%w_%.:]+%s-=%s-function%s-%([^%)]-%)',
                       '[%w_%.:%[%]]+%s-=%s-function%s-%([^%)]-%)' } }

types.tex= { pattern={'\\part{[^}]-}',
                       '\\chapter{[^}]-}',
                       '\\section{[^}]-}',
                       '\\subsection{[^}]-}',
                       '\\paragraph{[^}]-}',
                       '\\begin{document}' } }

types.far_hlf={ pattern={'^@.+'} }

types.python= { pattern={'class%s+[%w_]+',
                      '(def%s+[%w_]+%s-)%([^%)]-' } }

types.ini= { pattern={ '^%s-$', '^%[.+%]', multiline=true, linetoshow=2 } }
types.shell = { pattern={'^%s-[^%(]+%s-%(%s-%)'} }
types.fish = { pattern={'^%s-function%s+(%S+)'} }
types.txt = { pattern={ '^%s-[%d\.\)]+%s-.+' } }
types.makefile = { pattern={'^[^#\t][^:]+:[^=]'} }

return types
