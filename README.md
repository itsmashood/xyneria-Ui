# XyneriaUI — WindUI-based edition

This is a Xyneria-branded wrapper around **WindUI**.

## Why this approach

WindUI already provides the difficult UI infrastructure: resizable windows, tabs, toggles, buttons, sliders, dropdowns, notifications, config persistence, themes, icons, mobile scaling, and an open/close button.

`XyneriaUI_Wind.lua` keeps that engine but registers a custom Xyneria theme and exposes a small Xyneria convenience API.

## Files

- `XyneriaUI_Wind.lua` — Xyneria wrapper/library.
- `XyneriaUI_Demo.lua` — safe interactive demo.
- `LICENSE-WindUI.txt` — required upstream MIT attribution.
- `README.md` — this file.

## Quick start

Host `XyneriaUI_Wind.lua` somewhere your Roblox Lua environment can reach.

Then:

```lua
local XyneriaUI = loadstring(game:HttpGet("YOUR_XYNERIA_UI_URL"))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "EXPLOIT WITH CONFIDENCE.",
    Version = "v1.0.0",
})

local Home = App:Tab({
    Title = "Home",
    Icon = "house",
})

Home:Button({
    Title = "Run Action",
    Icon = "play",
    Callback = function()
        App:Notify("XYNERIA", "Button clicked.")
    end,
})

Home:Toggle({
    Title = "Example Toggle",
    Value = false,
    Callback = function(state)
        print("Toggle:", state)
    end,
})

Home:Slider({
    Title = "Example Slider",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
    },
    Callback = function(value)
        print("Slider:", value)
    end,
})

Home:Dropdown({
    Title = "Example Dropdown",
    Values = { "A", "B", "C" },
    Value = 1,
    Callback = function(value)
        print("Selected:", value)
    end,
})
```

## Xyneria visual direction

- Near-black / purple background.
- Purple-to-pink gradient accents.
- Rounded panels.
- Compact left sidebar.
- Top status tags.
- User panel.
- Draggable/resizable window.
- RightShift toggle key.
- Mobile-friendly floating X open button.

## Upstream dependency

The wrapper currently loads:

```text
https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua
```

For a production release, consider self-hosting a known-good WindUI snapshot rather than depending on the moving `main` branch.

WindUI is licensed under MIT. Keep `LICENSE-WindUI.txt` with any distribution that includes or substantially incorporates WindUI.
