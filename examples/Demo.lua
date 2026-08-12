local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOU/YOUR_REPO/main/dist/XyneriaUI.lua"
))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "EXPLOIT WITH CONFIDENCE.",
    Version = "v3.0.0",
    Live = true,
})

local Home = App:Tab({ Title = "Home", Icon = "house" })

Home:Paragraph({
    Title = "Independent core",
    Desc = "The UI, controls, state and config layer are provided by XyneriaUI itself.",
})

Home:Button({
    Title = "Run Action",
    Callback = function()
        App:Notify("XYNERIA", "Action completed.")
    end,
})

Home:Toggle({
    Title = "Feature",
    Value = false,
    Flag = "FeatureEnabled",
    Callback = function(value)
        print("feature", value)
    end,
})

Home:Slider({
    Title = "Power",
    Min = 0,
    Max = 100,
    Value = 50,
    Flag = "Power",
    Callback = function(value)
        print("power", value)
    end,
})

Home:Dropdown({
    Title = "Mode",
    Values = {"Normal", "Fast", "Safe"},
    Value = "Normal",
    Flag = "Mode",
})

local Settings = App:Tab({ Title = "Settings", Icon = "settings" })
Settings:Keybind({
    Title = "Action key",
    Value = Enum.KeyCode.F,
    Callback = function()
        App:Pulse()
    end,
})
Settings:Colorpicker({
    Title = "Example color",
    Value = "#D85DFF",
    Flag = "ExampleColor",
})
Settings:Button({ Title = "Save config", Callback = function() App:SaveConfig("default") end })
Settings:Button({ Title = "Load config", Callback = function() App:LoadConfig("default") end })
