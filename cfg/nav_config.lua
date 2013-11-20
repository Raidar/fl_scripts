local types={}
local paths = {".","%INCLUDE%","..\\include"}
local paths2 = {"."}
types.c= { patterns={'^%s-[#]include%s+["<]([^"<>]+)[">]'},
           paths=paths,
           source_paths={'..\\src','.'},
           source_extensions={'.cxx','.cc','.C','.cpp','.icc'} }
types.lua = { patterns={'require%s-[\'"(]+(.+)[\'"(]+','dopath%s-[\'"(]+(.+)[\'"(]+','dofile%s-[\'"(]+(.+)[\'"(]+'},
              extensions={'.lua'},
              paths=paths2 }
types.tex = { patterns={'\\include{(.+)}','\\input{(.+)}'} ,
              extensions={'.tex'},
              paths=paths2 }
types.makefile= { patterns={'^%s-%-?include%s+(.+)'}, paths=paths }

return types
