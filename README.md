# luanimath

A source-derived, Lua-native port of Manim Community Edition. The compatibility
target is **Manim 0.22.1**. This is an early development release in a continuing
port: consult `COMPATIBILITY.md` and the machine-readable inventory for its
verified scope. It does not yet replace the full upstream library.

The project lives in `/mnt/datos/luanimath`. The Lua entrypoint is
`require("luanimath")` and the CLI is `tools/luanimath.lua`.

The animation engine runs in Lua 5.4. A small C module interfaces directly with
Cairo. FFmpeg encodes actual frames. Python and Manim are **development-only
reference tools**, never part of scene execution or rendering.

## Build

Required: Lua 5.4 and development headers, a C11 compiler, make, pkg-config,
Cairo, Pango and libxml2 development libraries, and FFmpeg. Check existing installations
before installing anything. Mathematical expressions additionally need the native
`typst` CLI (tested with 0.15.1); full checks and the documentation gallery
require it. Set `LUANIMATH_TYPST` or the `typst_bin` option for its path. On Arch the relevant package names are `lua54`,
`cairo`, `pango`, `libxml2`, `ffmpeg`, `gcc`, `make` and `pkgconf`.

```sh
make
make test
make demo
make three-d-demo
make svg-demo
make glyph-demo
make markup-demo
```

The default module links specifically to Lua 5.4, even when the system `lua`
command is another version. Override `LUA` and `LUA_PKG` together when testing
another ABI; other ABIs have not yet been validated.

## Write a scene

Available native subsystems include cubic geometry and hierarchy transforms,
animation/composition, numerical axes and graphs, Pango-shaped Unicode text,
linear/logarithmic scales, moving cameras, 3D projection and lighting, Cube, Sphere, parametric Surface,
circular endpoint arcs, rounded polygons, native SVG paths/import, and native-CLI Typst mathematical expressions.
Availability and compatibility are tracked separately for each upstream API.

```lua
local l = require('luanimath')

return l.Scene(function(s)
    local square = l.Square { color = l.BLUE, fill_opacity = 0.3 }
    s:play(l.Create(square))
    s:play(square:animate():shift(2 * l.RIGHT), { run_time = 2 })
    s:play(l.Rotate(square, l.PI / 2))
    s:wait(0.5)
end)
```

Render from the repository root:

```sh
lua5.4 tools/luanimath.lua examples/geometric.lua \
    --output artifacts/geometric.mp4 --width 640 --height 360 --fps 24
```

PNG, MP4, GIF and WebM outputs are accepted. MP4 requires even pixel dimensions
with the current yuv420p encoder. The default is 854×480, 30 fps, eight scene
units high. Like Manim, the world frame defaults to 128/9 × 8 independently
of pixel resolution; set `frame_width`/`frame_height` explicitly for other world
aspect ratios.
For programmatic use set `LUA_PATH` to `lua/?.lua;lua/?/init.lua;;` and
`LUA_CPATH` to `build/?.so;;`.

Constructor options use Lua tables; operations use colon calls. Vector
arithmetic uses `l.vec(x,y,z)` and constants such as `l.RIGHT`. Dimension and
sequence indices are **1-based**, including `stretch(factor, dimension)`.
Angles are radians. Mobject point arrays contain four control points per cubic.

SVG files use `l.SVGMobject("drawing.svg", {height=2})`; raw path data uses
`l.VMobjectFromSVGPath("M0 0 C1 2 3 2 4 0")`. SVG default centering and height
follow Manim. Set `height=false` for Lua’s equivalent of Python `height=None`.
Supported elements, paints and restrictions are listed in `COMPATIBILITY.md`.

Text contains real glyph Mobjects. `text[1]`, `#text`, `ipairs(text)` and
`text.chars` access them; `text:slice(1,3)` returns a group sharing those
letters, so styling/animation affects the actual text. Slice endpoints are
inclusive and 1-based; negative indices count from the end. `text.font_size`
tracks geometric scaling and accepts a new positive size. Ligatures can
combine characters; use `disable_ligatures=true` when character mapping is
needed, subject to the font’s shaping behavior. `Write` and `Unwrite` operate
on the individual glyphs.

`l.MarkupText('<b>Lua</b> <span foreground="red">nativo</span>')` uses native
Pango markup, including Unicode, nested styles, size changes, underlines and
super/subscripts. `Text` supports `t2c`, `t2f`, `t2w`, `t2s`, `t2g` and their
`text2...` aliases, plus `gradient={l.RED,l.BLUE}`. For example:

```lua
local title = l.Text('Animate Lua', {
    font = 'Noto Sans', t2c = { Lua = l.BLUE }, t2w = { Lua = l.BOLD }
})
```

String selectors such as `"[0:3]"` retain Manim’s selector grammar: zero-based
start, exclusive end. They are distinct from Lua’s 1-based `slice` method.
Conflicting overlapping styles raise an error, following upstream. Object
families also support `group:set_color_by_gradient(l.RED,l.BLUE)`.

## Mathematical expressions

`Typst` compiles Typst document content; `MathTypst` accepts a math expression.
The native compiler produces SVG imported into the same Lua vector model.
No Python runs during compilation, selection, animation or rendering.

```lua
local equation = l.MathTypst('{{ a^2+b^2 : lhs }} = {{ c^2 }}', {font_size=72})
equation:select('lhs'):set_color(l.BLUE)
equation:select(1):set_color(l.YELLOW) -- first unnamed capture, Lua indexing
```

Nested/repeated captures, ordinary Typst labels and optional affine baseline
tracking have differential tests. Typst syntax differs from LaTeX; MathTex/Tex
and expression-matching animations remain pending. See the manual for cache
limits and the explicitly diagnosed upstream SVG-cache tracking difference.

## Documentation

[English manual](https://48hoursnonstop.github.io/luanimath/en/) ·
[Manual en español](https://48hoursnonstop.github.io/luanimath/es/)

The English and Spanish manuals include tutorials, a rendered gallery, API
signatures, supported options/defaults, return contracts and compatibility
limits. Build both languages with:

```sh
python3 -m venv --system-site-packages .dev/venv
.dev/venv/bin/python -m pip install -r docs/requirements.txt
make docs DOC_PYTHON=.dev/venv/bin/python
```

Open `artifacts/docs/en/index.html` or `artifacts/docs/es/index.html`. The
build executes all eleven gallery scenes, decodes the actual media and checks
local links. `make docs-api-check` detects new exports without bilingual
reference entries. Source releases also build the manuals from the clean
extraction; use `make release DOC_PYTHON=.dev/venv/bin/python` with the docs
build dependencies installed. Documentation Python is a development tool.

## Verification

The image tests use Liberation Sans, Noto Sans, Noto Sans Arabic and Noto Sans
CJK JP. `compatibility/reference_environment.json` records exact reference
library versions and font hashes. Missing/different fonts can produce real
environmental differences; do not interpret fallback-font output as parity.

`make check` builds the native module, runs the Lua regression suite, renders
and decodes a real animation, and compares the port to frozen outputs generated
by real Manim 0.22.1. Development image comparisons require Python 3, NumPy
and Pillow; the Lua runtime itself does not.

`make reference` regenerates the fixtures and API inventory using the isolated
environment at `.dev/venv` and pinned source at `.dev/manim-0.22.1`. See
`UPSTREAM.md`. `make sanitize` runs the regression suite with ASan/UBSan and
then restores the normal build. `make release` packages source and reference
test data, extracts it into a new directory, rebuilds and runs `make check`.

See `TEST_RESULTS.md` for executed results, `ARCHITECTURE.md` for subsystem
boundaries, and `ROADMAP.md` for the next dependency-ordered work.

## License

MIT. Retained upstream notices are in `LICENSE.manim` and
`LICENSE.manim-community`; see `UPSTREAM.md` for attribution and source pinning.
