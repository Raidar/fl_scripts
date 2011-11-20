local types={}
types.default     = { line = '#' }
types.fortran     = { line = '*' }
types.tex         = { line = '%' }
types.postscript  = { line = '%' }
types.message     = { line = '>' }
types.ini         = { line = ';' }
types.c           = { line='//', left='/*',   right='*/', skipSpaces=true  }
types.lua         = { line='--', left='--[[', right=']]', skipSpaces=true  }
types.xml         = {            left='<!--', right='-->' }

return types
