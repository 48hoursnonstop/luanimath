Development and documentation
================================================================================

The compatibility reference is pinned to Manim Community 0.22.1. Inspect the
source before implementing a subsystem, run the actual public Lua API and record
numerical/visual differences. The machine-readable API inventory separates
availability, partial behavior, verified behavior and blocked subsystems.

Checks
--------------------------------------------------------------------------------

``make check`` runs functional, frozen differential, image and real media checks.
Development comparisons require Python, NumPy and Pillow. ``make sanitize``
exercises native boundaries with ASan/UBSan and restores the normal build.
``make reference`` regenerates fixtures using the isolated pinned upstream oracle.

Documentation is part of the feature
--------------------------------------------------------------------------------

For every public addition:

1. Add accurate English and Spanish descriptions in ``docs/catalog.py`` and
   parameter meanings in ``docs/parameters.py``.
2. Document supported options, defaults, results and compatibility limits.
3. Update the relevant tutorial and complete scene example when applicable.
4. Execute tests and run the API documentation check. It detects missing exports,
   stale descriptions and missing parameter translations.
5. Build both manuals with warnings treated as errors. The build renders and
   decodes every gallery scene and checks local links and anchors.

Install the pinned packages in ``docs/requirements.txt`` in a development virtual
environment. Run ``tools/docs.py check`` for the API check and ``tools/docs.py
build`` with that environment’s Python for both HTML manuals.

Release evidence
--------------------------------------------------------------------------------

Source releases must pass compilation, actual examples, regressions, updated
documentation, SHA-256 manifest validation and a clean extraction/rebuild.
Do not promote a partial API based on its name or one passing example.
