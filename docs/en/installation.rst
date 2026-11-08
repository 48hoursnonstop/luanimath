Installation
================================================================================

Build on Linux
--------------------------------------------------------------------------------

You need Lua 5.4 and its development headers, a C11 compiler, make, pkg-config,
Cairo, Pango, libxml2 and FFmpeg. Check existing tools before installing packages.
On Arch, the relevant packages are ``lua54 cairo pango libxml2 ffmpeg gcc make
pkgconf``. Lua 5.4 is the only tested ABI; a system ``lua`` command may use another
version.

.. code-block:: console

   git clone https://github.com/48hoursnonstop/luanimath.git
   cd luanimath
   make
   make test
   lua5.4 tools/luanimath.lua docs/examples/quickstart.lua --output animation.mp4

The CLI locates Lua modules relative to its own source file. For a custom Lua
entrypoint, set ``LUA_PATH`` to ``lua/?.lua;lua/?/init.lua;;`` and ``LUA_CPATH`` to
``build/?.so;;``, using absolute paths when running outside the project directory.

Dependencies at runtime
--------------------------------------------------------------------------------

Scene execution uses Lua and the native Cairo/Pango/libxml2 module. FFmpeg is
needed for encoded animation. Python and upstream Manim are development tools
for reference testing and documentation builds; they do not execute Lua scenes.
TeX/Typst-backed public math objects remain in progress in this release.

Fonts
--------------------------------------------------------------------------------

Examples use Liberation Sans and Noto Sans. CJK/Arabic examples need the matching
Noto font families. ``font_list()`` reports the available Pango families. Font
fallback can alter layout; the reference environment records tested font hashes.

Source archives
--------------------------------------------------------------------------------

Release tarballs contain source, tests and frozen reference data. Extract an
archive, enter its directory and run ``make``. SHA-256 and a clean rebuild report
accompany each verified development release.
