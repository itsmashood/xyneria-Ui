# XyneriaUI

XyneriaUI is a self-contained Roblox/Luau interface library with its own windowing, controls, notifications, state and optional config persistence.

## Project layout

- `src/Theme.lua` — palette and gradients
- `src/Util.lua` — GUI and animation helpers
- `src/Config.lua` — optional JSON config persistence
- `src/Controls.lua` — control implementations
- `src/Window.lua` — window, sidebar, tabs and dialogs
- `src/XyneriaUI.lua` — public API
- `build/build.py` — creates the standalone `dist/XyneriaUI.lua`
- `build/verify.py` — repository reference audit
- `examples/Demo.lua` — usage example

## Build

```bash
python build/build.py
```

## Runtime use

```lua
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOU/YOUR_REPO/main/dist/XyneriaUI.lua"
))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Version = "v3.0.0",
})
```

## Supported public surface

Library calls: `GetCore`, `GetStyle`, `SetTheme`, `Notify`, `CreateWindow`.

App calls: `Tab`, `Section`, `Divider`, `SelectTab`, `Notify`, `Dialog`, `Open`, `Close`, `Toggle`, `Destroy`, `SetTitle`, `SetAuthor`, `SetScale`, `SetEffects`, `Pulse`, `GetStyle`, `SaveConfig`, `LoadConfig`.

Container controls: `Paragraph`, `Button`, `Toggle`, `Slider`, `ProgressBar`, `Keybind`, `Input`, `Dropdown`, `Code`, `Colorpicker`, `Section`, `Divider`, `Space`, `Image`, `Group`, `VStack`, `HStack`, `Viewport`.

No icon package is fetched at runtime. Icon fields are accepted for script compatibility but the core does not depend on a remote icon service.
