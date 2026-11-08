LUA ?= lua5.4
LUA_PKG ?= lua5.4
PYTHON ?= python3
DOC_PYTHON ?= python3
export DOC_PYTHON
CC ?= cc
CFLAGS ?= -O2 -g
WARN = -std=c11 -Wall -Wextra -Werror -Wpedantic
PKGS = $(LUA_PKG) cairo pangocairo libxml-2.0
export LUA_PATH := $(CURDIR)/lua/?.lua;$(CURDIR)/lua/?/init.lua;;
export LUA_CPATH := $(CURDIR)/build/?.so;;

.PHONY: all test docs docs-check docs-api-check text-test text-features-test markup-demo growth-test rounding-test colors-test scales-test typst-test glyph-test glyph-demo svg-test svg-demo media-test graphing-test alignment-test paths-test three-d-test three-d-demo demo reference differential check clean sanitize release
all: build/luanimath_native.so

build/luanimath_native.so: native/cairo_backend.c native/text.c native/xml.c native/system.c
	@mkdir -p build
	$(CC) $(CFLAGS) $(WARN) -fPIC -shared $^ -o $@ $$(pkg-config --cflags --libs $(PKGS)) -lm

test: all
	$(LUA) tests/run.lua

docs-api-check: all
	$(PYTHON) tools/docs.py check

docs docs-check: all
	$(DOC_PYTHON) tools/docs.py build

demo: all
	$(LUA) tools/luanimath.lua examples/geometric.lua --output artifacts/geometric.mp4 --width 640 --height 360 --fps 24

reference:
	.dev/venv/bin/python tools/reference.py --upstream .dev/manim-0.22.1
	.dev/venv/bin/python tools/reference_text.py
	.dev/venv/bin/python tools/reference_graphing.py
	.dev/venv/bin/python tools/reference_alignment.py
	.dev/venv/bin/python tools/reference_paths.py
	.dev/venv/bin/python tools/reference_three_d.py
	.dev/venv/bin/python tools/reference_svg.py
	.dev/venv/bin/python tools/reference_glyphs.py
	.dev/venv/bin/python tools/reference_markup.py
	.dev/venv/bin/python tools/reference_text_styles.py
	.dev/venv/bin/python tools/reference_typst.py
	.dev/venv/bin/python tools/reference_scales.py
	.dev/venv/bin/python tools/reference_colors.py
	.dev/venv/bin/python tools/reference_rounding.py
	.dev/venv/bin/python tools/reference_growth.py

growth-test: all
	$(LUA) tests/growth.lua
	$(PYTHON) tools/visual_growth.py

rounding-test: all
	$(LUA) tests/rounding.lua
	$(PYTHON) tools/visual_rounding.py

colors-test: all
	$(LUA) tests/colors.lua
	$(PYTHON) tools/visual_colors.py

scales-test: all
	$(LUA) tests/scales.lua
	$(PYTHON) tools/visual_scales.py

typst-test: all
	$(LUA) tests/typst.lua
	$(PYTHON) tools/visual_typst.py

text-features-test: all
	$(LUA) tests/markup.lua
	$(LUA) tests/text_styles.lua
	$(PYTHON) tools/visual_text_features.py

markup-demo: all
	$(LUA) tools/luanimath.lua examples/markup.lua --output artifacts/markup.mp4 --width 640 --height 360 --fps 24
	$(PYTHON) tools/verify_markup_video.py

glyph-test: all
	$(LUA) tests/glyphs.lua
	$(PYTHON) tools/visual_glyphs.py

glyph-demo: all
	$(LUA) tools/luanimath.lua examples/glyphs.lua --output artifacts/glyphs.mp4 --width 640 --height 360 --fps 24
	$(PYTHON) tools/verify_glyph_video.py

svg-test: all
	$(LUA) tests/svg.lua
	$(PYTHON) tools/visual_svg.py

svg-demo: all
	$(LUA) tools/luanimath.lua examples/svg.lua --output artifacts/svg.mp4 --width 640 --height 360 --fps 24
	$(PYTHON) tools/verify_svg_video.py

three-d-test: all
	$(LUA) tests/three_d.lua
	$(PYTHON) tools/visual_three_d.py

three-d-demo: all
	$(LUA) tools/luanimath.lua examples/three_d.lua --output artifacts/three-d.mp4 --width 640 --height 360 --fps 24
	$(PYTHON) tools/verify_three_d_video.py

paths-test: all
	$(LUA) tests/paths.lua

alignment-test: all
	$(LUA) tests/alignment.lua
	$(PYTHON) tools/visual_alignment.py

graphing-test: all
	$(LUA) tests/graphing.lua
	$(PYTHON) tools/visual_graphing.py

text-test: all
	$(LUA) tests/text.lua
	$(PYTHON) tools/visual_text.py

media-test: all
	$(LUA) tests/media.lua
	$(PYTHON) tools/verify_media.py

differential: all
	$(LUA) tests/differential.lua
	$(PYTHON) tools/visual_compare.py

check: test demo differential text-test media-test graphing-test alignment-test paths-test three-d-test three-d-demo svg-test svg-demo glyph-test glyph-demo text-features-test markup-demo typst-test scales-test colors-test rounding-test growth-test docs-api-check

sanitize:
	$(MAKE) clean
	$(MAKE) CFLAGS='-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer'
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/run.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/text.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/alignment.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/three_d.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/svg.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/glyphs.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/markup.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/text_styles.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/typst.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/scales.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/colors.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/rounding.lua
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/growth.lua
	$(MAKE) clean
	$(MAKE) all

release:
	$(PYTHON) tools/release.py

clean:
	rm -rf build
