# Architecture

## Runtime

Your script fetches one standalone file from **your own** GitHub repository:

```lua
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOU/XyneriaUI/main/dist/XyneriaUI.lua"
))()
```

`dist/XyneriaUI.lua` already contains:

1. the vendored WindUI core;
2. WindUI's embedded standard icon packs;
3. the Xyneria theme;
4. the Xyneria wrapper API.

There is no second request to a Footagesus WindUI `CORE_URL`.

## Source layout

- `dist/XyneriaUI.lua` — use this in scripts.
- `src/` — Xyneria-specific source.
- `vendor/WindUI/` — full upstream snapshot from the supplied ZIP.
- `build/build.py` — reproducible standalone builder.
- `examples/` — starter scripts.
- `LICENSES/` — third-party licenses.

The vendored upstream files are not edited. Patches for the standalone build happen only while generating `dist/XyneriaUI.lua`.
