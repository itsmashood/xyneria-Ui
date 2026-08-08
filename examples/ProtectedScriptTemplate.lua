-- Your protected script can load XyneriaUI from YOUR repository.
local XyneriaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/dist/XyneriaUI.lua"
))()

local App = XyneriaUI:CreateWindow({
    Title = "XYNERIA",
    Author = "YOUR SCRIPT NAME",
    Version = "v1.0.0",
})

local Main = App:Tab({
    Title = "Main",
    Icon = "house",
})

Main:Button({
    Title = "Test",
    Icon = "play",
    Callback = function()
        App:Notify("XYNERIA", "Protected script loaded successfully.")
    end,
})
