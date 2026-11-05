LUA ?= lua5.4
LUA_PKG ?= lua5.4
PYTHON ?= python3
CC ?= cc
CFLAGS ?= -O2 -g
WARN = -std=c11 -Wall -Wextra -Werror -Wpedantic
PKGS = $(LUA_PKG) cairo pangocairo
export LUA_PATH := $(CURDIR)/lua/?.lua;$(CURDIR)/lua/?/init.lua;;
export LUA_CPATH := $(CURDIR)/build/?.so;;

.PHONY: all test demo reference differential check clean sanitize release
all: build/luanim_native.so

build/luanim_native.so: native/cairo_backend.c
	@mkdir -p build
	$(CC) $(CFLAGS) $(WARN) -fPIC -shared $< -o $@ $$(pkg-config --cflags --libs $(PKGS)) -lm

test: all
	$(LUA) tests/run.lua

demo: all
	$(LUA) tools/luanim.lua examples/geometric.lua --output artifacts/geometric.mp4 --width 640 --height 360 --fps 24

reference:
	.dev/venv/bin/python tools/reference.py --upstream .dev/manim-0.22.1

differential: all
	$(LUA) tests/differential.lua
	$(PYTHON) tools/visual_compare.py

check: test demo differential

sanitize:
	$(MAKE) clean
	$(MAKE) CFLAGS='-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer'
	ASAN_OPTIONS=detect_leaks=0 LD_PRELOAD="$$( $(CC) -print-file-name=libasan.so )" $(LUA) tests/run.lua
	$(MAKE) clean
	$(MAKE) all

release:
	python tools/release.py

clean:
	rm -rf build
