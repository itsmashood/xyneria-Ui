# XyneriaUI

A Xyneria-themed Roblox/Luau UI library built on a **locally vendored WindUI snapshot**.

## No Footagesus CORE_URL

The production file:

```text
dist/XyneriaUI.lua
```

contains the WindUI core and the Xyneria wrapper in one standalone file.

After you upload this repository, your script only requests **your own** raw GitHub file:

```lua
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/dist/XyneriaUI.lua"
))()
```

It does not download WindUI from Footagesus at runtime.

## Repository contents

- Full WindUI repository under `vendor/WindUI/`
- Original WindUI MIT license
- Standalone `dist/XyneriaUI.lua`
- Xyneria purple/pink theme
- Xyneria wrapper API
- Examples
- Build script
- Dependency audit
- Upstream checksums

## Quick example

```lua
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOU/XyneriaUI/main/dist/XyneriaUI.lua"
))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "EXPLOIT WITH CONFIDENCE.",
    Version = "v1.0.0",
})

local Home = App:Tab({ Title = "Home", Icon = "house" })

Home:Button({
    Title = "Test",
    Callback = function()
        App:Notify("XYNERIA", "Working.")
    end,
})
```

## Rebuild

After editing `src/XyneriaWrapper.lua`:

```bash
python build/build.py
```

Commit the regenerated `dist/XyneriaUI.lua`.

## Attribution

WindUI is MIT licensed. Its license and attribution are intentionally preserved.

See `THIRD_PARTY_NOTICES.md`, `LICENSES/WindUI-MIT.txt`, and `UPSTREAM.md`.
