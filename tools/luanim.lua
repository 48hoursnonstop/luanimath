-- Public CLI uses Lua 5.4 only; Python is development-only.
local script=arg[0]:gsub('\\','/')
local root=script:match('^(.*)/tools/[^/]+$') or '.'
package.path=root..'/lua/?.lua;'..root..'/lua/?/init.lua;'..package.path
package.cpath=root..'/build/?.so;'..package.cpath
local function usage()
    print('Usage: lua5.4 tools/luanim.lua SCENE.lua [--output FILE.mp4|.gif|.png|.webm] [--width N --height N --fps N] [--keep-frames]')
end
if not arg[1] or arg[1]=='--help' then usage();os.exit(0) end
local options={};local names={['--output']='output',['--width']='pixel_width',['--height']='pixel_height',['--fps']='frame_rate'}
local i=2
while i<=#arg do
    local key=arg[i]
    if key=='--keep-frames' then options.keep_frames=true;i=i+1
    elseif names[key] then
        assert(arg[i+1],'missing value for '..key)
        options[names[key]]=key=='--output' and arg[i+1] or assert(tonumber(arg[i+1]),'numeric option required')
        i=i+2
    else error('unknown option: '..key) end
end
local scene=assert(loadfile(arg[1]))()
assert(type(scene)=='table' and type(scene.render)=='function','scene file must return a Luanim Scene')
local result=scene:render(options)
print(('Rendered %d frames, %.6g seconds: %s'):format(result.frame_count,result.duration,result.output))
