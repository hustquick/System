# AGENTS.md — Software Design Standards

All contributors and coding agents must read [SOFTWARE_DESIGN_STANDARD.md](SOFTWARE_DESIGN_STANDARD.md) before proposing or changing UI, UX, keyboard shortcuts, editor behavior, input/output flows, or navigation.

Treat spatial stability, interaction continuity, platform-standard shortcuts, non-destructive editing, and LVSM as P0 requirements. For every change:
1. State the user task and expected improvement.
2. Identify affected core work areas and editor state.
3. Preserve geometry, selection, focus, scroll, zoom and undo history unless the user explicitly requests a change.
4. Run relevant regression tests and report results or verification limitations.
5. Explain any deviation before implementing it.

When reusing this standard in another repository, copy this file and the standard, or add a project-local AGENTS.md referencing the canonical URL:
https://github.com/hustquick/System/blob/master/SOFTWARE_DESIGN_STANDARD.md

## Mandatory delivery workflow
Before any development task, also read [DEVELOPMENT_DELIVERY_STANDARD.md](DEVELOPMENT_DELIVERY_STANDARD.md). For installable apps, completion requires build, tests, and—when running on the user's Mac with permissions—safe installation and launch of a separate development build for hands-on acceptance. If cloud-only, state that local installation was not performed. Never push, merge, or release without the user's explicit approval after acceptance. Report build, test, install, launch and remote status separately.

Canonical URL: https://github.com/hustquick/System/blob/master/DEVELOPMENT_DELIVERY_STANDARD.md
