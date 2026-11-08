local U=require('luanim.util')
local N=require('luanim_native')
local F={}
local function read(path)
    local f=io.open(path,'rb');if not f then return nil end
    local data=f:read('*a');f:close();return data
end
local function write(path,data)
    local f=assert(io.open(path,'wb'));assert(f:write(data));assert(f:close())
end
local function temporary(directory)
    local pipe=assert(io.popen('mktemp '..U.shell_quote(directory..'/.compile-XXXXXX'),'r'))
    local path=pipe:read('*l');local ok=pipe:close();assert(ok and path,'cannot create Typst staging file');return path
end
function F.typst_to_svg_file(body,opts)
    opts=opts or {};assert(type(body)=='string' and #body<=1048576 and not body:find('\0',1,true) and utf8.len(body),'Typst requires valid UTF-8 source, at most 1 MiB, without NUL')
    local preamble=opts.preamble or opts.typst_preamble or '';assert(type(preamble)=='string','Typst preamble must be a string')
    local size=U.number(opts.text_size or 10,'Typst compilation text_size');assert(size>0,'Typst text_size must be positive')
    local source=('#set page(width: auto, height: auto, margin: 0pt, fill: none)\n#set text(size: %spt)\n%s\n%s\n'):format(size,preamble,body)
    local compiler=opts.typst_bin or os.getenv('LUANIM_TYPST') or 'typst'
    local pipe=assert(io.popen(U.shell_quote(compiler)..' --version 2>&1','r'))
    local version=pipe:read('*a');local ok=pipe:close();assert(ok and version:match('^typst '),'Typst compiler is unavailable: '..version)
    local paths=opts.font_paths or {};assert(type(paths)=='table','font_paths must be a sequence')
    local key={source,version,opts.root or ''}
    for _,path in ipairs(paths) do assert(type(path)=='string','font path must be a string');key[#key+1]=path end
    local hash=N.sha256(table.concat(key,'\0'))
    local directory=opts.cache_dir or '.luanim-cache/typst';U.mkdir(directory)
    local stem=directory..'/'..hash;local svg,typ=stem..'.svg',stem..'.typ'
    if read(typ)~=source then local stage=temporary(directory);write(stage,source);assert(os.rename(stage,typ)) end
    local cached=read(svg);local digest=read(svg..'.sha256')
    if opts.use_cache~=false and cached and digest==N.sha256(cached)..'\n' then return svg end
    local stage=temporary(directory)
    local args={compiler,'compile','--format','svg',typ,stage}
    for _,path in ipairs(paths) do args[#args+1]='--font-path';args[#args+1]=path end
    if opts.root then args[#args+1]='--root';args[#args+1]=opts.root end
    U.command(args)
    local data=assert(read(stage),'Typst did not produce an SVG');assert(N.parse_xml(data).name=='svg','Typst output is not an SVG document')
    local digest_stage=temporary(directory);write(digest_stage,N.sha256(data)..'\n')
    assert(os.rename(stage,svg));assert(os.rename(digest_stage,svg..'.sha256'))
    return svg
end
return F
