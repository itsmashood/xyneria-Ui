--[[
    XyneriaUI_Demo.lua
    Safe interactive demo for XyneriaUI_Wind.lua.

    Replace YOUR_XYNERIA_UI_URL with wherever you host XyneriaUI_Wind.lua.
]]

local XyneriaUI = loadstring(game:HttpGet("YOUR_XYNERIA_UI_URL"))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "EXPLOIT WITH CONFIDENCE.",
    Version = "v1.0.0",
    Live = true,
    StatusTitle = "ALL SCRIPTS LIVE",
})

if not App then
    return
end

local Home = App:Tab({
    Title = "Home",
    Icon = "house",
})

Home:Button({
    Title = "Welcome to Xyneria",
    Icon = "sparkles",
    Callback = function()
        App:Notify(
            "XYNERIA",
            "Purple, pink, clean, and fully interactive.",
            "sparkles",
            4
        )
    end,
})

Home:Space()

Home:Toggle({
    Title = "Demo Toggle",
    Value = false,
    Flag = "DemoToggle",
    Callback = function(state)
        App:Notify(
            "Demo Toggle",
            state and "Enabled" or "Disabled",
            state and "check" or "x",
            2
        )
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

Home:Space()

Home:Dropdown({
    Title = "Demo Mode",
    Values = {
        "Normal",
        "Compact",
        "Showcase",
    },
    Value = 1,
    Flag = "DemoMode",
    Callback = function(value)
        App:Notify(
            "Mode Changed",
            "Selected: " .. tostring(value),
            "layers",
            2
        )
    end,
})

local Scripts = App:Tab({
    Title = "Scripts",
    Icon = "code-2",
})

Scripts:Button({
    Title = "Example Script Card",
    Icon = "play",
    Callback = function()
        App:Notify(
            "Example",
            "Put your own script callback here.",
            "code-2",
            3
        )
    end,
})

Scripts:Space()

Scripts:Toggle({
    Title = "Example Feature",
    Value = false,
    Flag = "ExampleFeature",
    Callback = function(state)
        print("[Xyneria Demo] Example feature:", state)
    end,
})

local Player = App:Tab({
    Title = "Player",
    Icon = "user",
})

Player:Slider({
    Title = "Example Value",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
    },
    Flag = "ExampleValue",
    Callback = function(value)
        print("[Xyneria Demo] Example value:", value)
    end,
})

Player:Space()

Player:Dropdown({
    Title = "Example Selection",
    Values = {
        "Option A",
        "Option B",
        "Option C",
    },
    Value = 1,
    Flag = "ExampleSelection",
    Callback = function(value)
        print("[Xyneria Demo] Selection:", value)
    end,
})

local Settings = App:Tab({
    Title = "Settings",
    Icon = "settings",
})

Settings:Button({
    Title = "Save UI Config",
    Icon = "save",
    Callback = function()
        local ok = App:SaveConfig("default")

        App:Notify(
            "Configuration",
            ok and "Saved successfully." or "Could not save configuration.",
            ok and "check" or "triangle-alert",
            3
        )
    end,
})

Settings:Space()

Settings:Button({
    Title = "Load UI Config",
    Icon = "folder-open",
    Callback = function()
        local ok = App:LoadConfig("default")

        App:Notify(
            "Configuration",
            ok and "Loaded successfully." or "Could not load configuration.",
            ok and "check" or "triangle-alert",
            3
        )
    end,
})

Settings:Space()

Settings:Button({
    Title = "Xyneria Website",
    Icon = "external-link",
    Callback = function()
        local url = "https://xyneria.com/"

        if type(setclipboard) == "function" then
            setclipboard(url)

            App:Notify(
                "XYNERIA",
                "Website copied to clipboard.",
                "clipboard",
                3
            )
        else
            App:Notify(
                "XYNERIA",
                url,
                "external-link",
                5
            )
        end
    end,
})
