# Common controls

The Xyneria wrapper returns WindUI tab objects, so the full WindUI element API remains available.

```lua
Tab:Button({
    Title = "Button",
    Callback = function() end,
})

Tab:Toggle({
    Title = "Toggle",
    Value = false,
    Callback = function(value) end,
})

Tab:Slider({
    Title = "Slider",
    Step = 1,
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value) end,
})

Tab:Dropdown({
    Title = "Dropdown",
    Values = { "A", "B", "C" },
    Value = 1,
    Callback = function(value) end,
})
```

The full upstream WindUI source tree is preserved in `vendor/WindUI/src/`.
