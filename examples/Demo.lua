-- After uploading this repository, replace YOUR_GITHUB_USERNAME/YOUR_REPO.
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/dist/XyneriaUI.lua"
))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "EXPLOIT WITH CONFIDENCE.",
    Version = "v1.0.0",
    Live = true,
})

local Home = App:Tab({
    Title = "Home",
    Icon = "house",
})

Home:Button({
    Title = "Interactive Button",
    Icon = "mouse-pointer-click",
    Callback = function()
        App:Notify("XYNERIA", "The button works.", "sparkles", 3)
    end,
})

Home:Space()

Home:Toggle({
    Title = "Interactive Toggle",
    Value = false,
    Flag = "ExampleToggle",
    Callback = function(state)
        print("[Xyneria] Toggle:", state)
    end,
})

Home:Space()

Home:Slider({
    Title = "Interface Scale",
    Step = 0.05,
    Value = {
        Min = 0.70,
        Max = 1.10,
        Default = 1.00,
    },
    Callback = function(value)
        App:SetScale(value)
    end,
})

local Settings = App:Tab({
    Title = "Settings",
    Icon = "settings",
})

Settings:Dropdown({
    Title = "Mode",
    Values = { "Normal", "Compact", "Showcase" },
    Value = 1,
    Flag = "Mode",
    Callback = function(value)
        App:Notify("Mode", "Selected " .. tostring(value), "layers", 2)
    end,
})
