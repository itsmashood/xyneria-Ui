--[[
    XyneriaUI_Wind.lua

    Xyneria-branded UI wrapper powered by WindUI.
    WindUI copyright (c) 2026 Footages, licensed under the MIT License.
    See LICENSE-WindUI.txt in the distribution pack.

    This file is Xyneria's own theme + convenience API. It loads WindUI's
    compiled core, registers the "Xyneria" theme, and exposes a small wrapper
    suitable for future scripts.

    Basic usage:
        local XyneriaUI = loadstring(game:HttpGet("YOUR_XYNERIA_UI_URL"))()

        local App = XyneriaUI:CreateWindow({
            Title = "XYNERIA",
            Author = "EXPLOIT WITH CONFIDENCE.",
            Version = "v1.0.0",
        })

        local Main = App:Tab({ Title = "Home", Icon = "house" })

        Main:Button({
            Title = "Run Action",
            Icon = "play",
            Callback = function()
                App:Notify("Done", "The button works.")
            end,
        })
]]

local CORE_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

local coreSource = game:HttpGet(CORE_URL)
local compile, compileError = loadstring(coreSource)

if not compile then
    error("[XyneriaUI] Failed to compile WindUI core: " .. tostring(compileError))
end

local WindUI = compile()
if not WindUI then
    error("[XyneriaUI] WindUI core did not return a library table.")
end

local XyneriaUI = {}
XyneriaUI.__index = XyneriaUI

XyneriaUI.CoreURL = CORE_URL
XyneriaUI.Core = WindUI
XyneriaUI.Version = "1.0.0"

local themeReady = false

local function XGradient(leftHex, rightHex, rotation)
    return WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromHex(leftHex),
            Transparency = 0,
        },
        ["100"] = {
            Color = Color3.fromHex(rightHex),
            Transparency = 0,
        },
    }, {
        Rotation = rotation or 0,
    })
end

local function ensureTheme()
    if themeReady then
        return
    end

    WindUI:AddTheme({
        Name = "Xyneria",

        -- Purple -> pink visual identity from xyneria.com
        Accent = XGradient("#7957FF", "#FF4FCB", 0),
        Background = XGradient("#050308", "#110718", 90),
        Dialog = Color3.fromHex("#0D0712"),
        Outline = Color3.fromHex("#3C2449"),

        Text = Color3.fromHex("#F9F4FC"),
        Placeholder = Color3.fromHex("#8D7F98"),

        Button = XGradient("#23112F", "#34113C", 0),
        Icon = Color3.fromHex("#E899FF"),

        Toggle = XGradient("#885CFF", "#F45CD2", 0),
        Slider = Color3.fromHex("#D65CFF"),
        Checkbox = XGradient("#885CFF", "#F45CD2", 0),
        Primary = Color3.fromHex("#D85DFF"),

        PanelBackground = Color3.fromHex("#120A18"),
        PanelBackgroundTransparency = 0.08,

        LabelBackground = Color3.fromHex("#0F0814"),
        LabelBackgroundTransparency = 0.06,
    })

    themeReady = true
end

local function merge(defaults, incoming)
    local result = {}

    for key, value in pairs(defaults) do
        result[key] = value
    end

    for key, value in pairs(incoming or {}) do
        if type(value) == "table" and type(result[key]) == "table" then
            local nested = {}
            for nk, nv in pairs(result[key]) do
                nested[nk] = nv
            end
            for nk, nv in pairs(value) do
                nested[nk] = nv
            end
            result[key] = nested
        else
            result[key] = value
        end
    end

    return result
end

local function createApp(window)
    local App = {
        Window = window,
        Core = WindUI,
    }

    function App:Tab(config)
        return self.Window:Tab(config)
    end

    function App:Section(config)
        return self.Window:Section(config)
    end

    function App:Divider()
        return self.Window:Divider()
    end

    function App:SelectTab(tab)
        return self.Window:SelectTab(tab)
    end

    function App:Notify(title, content, icon, duration)
        WindUI:Notify({
            Title = title or "XYNERIA",
            Content = content or "",
            Icon = icon or "sparkles",
            Duration = duration or 4,
        })
    end

    function App:Dialog(config)
        return self.Window:Dialog(config)
    end

    function App:Open()
        return self.Window:Open()
    end

    function App:Close()
        return self.Window:Close()
    end

    function App:Toggle()
        return self.Window:Toggle()
    end

    function App:Destroy()
        return self.Window:Destroy()
    end

    function App:SetTitle(title)
        return self.Window:SetTitle(title)
    end

    function App:SetAuthor(author)
        return self.Window:SetAuthor(author)
    end

    function App:SetScale(scale)
        return self.Window:SetUIScale(scale)
    end

    function App:SaveConfig(name)
        if not self.Window.ConfigManager then
            return false, "Config manager is unavailable."
        end

        local ok, result = pcall(function()
            return self.Window.ConfigManager:Config(name or "default"):Save()
        end)

        return ok, result
    end

    function App:LoadConfig(name)
        if not self.Window.ConfigManager then
            return false, "Config manager is unavailable."
        end

        local ok, result = pcall(function()
            return self.Window.ConfigManager:Config(name or "default"):Load()
        end)

        return ok, result
    end

    return App
end

function XyneriaUI:GetCore()
    ensureTheme()
    return WindUI
end

function XyneriaUI:SetTheme(name)
    ensureTheme()
    return WindUI:SetTheme(name or "Xyneria")
end

function XyneriaUI:Notify(title, content, icon, duration)
    ensureTheme()

    return WindUI:Notify({
        Title = title or "XYNERIA",
        Content = content or "",
        Icon = icon or "sparkles",
        Duration = duration or 4,
    })
end

function XyneriaUI:CreateWindow(options)
    ensureTheme()

    options = options or {}

    local defaults = {
        Title = "XYNERIA",
        Author = "EXPLOIT WITH CONFIDENCE.",
        Folder = "Xyneria",
        Icon = options.Icon or "sparkles",
        Theme = "Xyneria",

        Size = UDim2.fromOffset(720, 470),
        MinSize = Vector2.new(560, 350),
        MaxSize = Vector2.new(960, 680),

        Radius = 18,
        Transparent = true,
        Acrylic = true,
        ShadowTransparency = 0.45,

        Resizable = true,
        AutoScale = true,
        NewElements = true,

        SideBarWidth = 176,
        HideSearchBar = true,
        ScrollBarEnabled = false,

        ToggleKey = Enum.KeyCode.RightShift,

        Topbar = {
            Height = 48,
            ButtonsType = "Default",
        },

        OpenButton = {
            Title = "X",
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 0.46,
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 2,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#7957FF")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#FF4FCB")),
            }),
        },

        User = {
            Enabled = true,
            Anonymous = false,
            Callback = options.OnUserClick or function()
                WindUI:Notify({
                    Title = "XYNERIA",
                    Content = "User panel selected.",
                    Icon = "user",
                    Duration = 2,
                })
            end,
        },
    }

    local config = merge(defaults, options)

    -- Wrapper-only options are removed before forwarding to WindUI.
    local version = config.Version
    local live = config.Live
    local statusTitle = config.StatusTitle

    config.Version = nil
    config.Live = nil
    config.StatusTitle = nil
    config.OnUserClick = nil

    local window = WindUI:CreateWindow(config)

    if not window then
        return nil
    end

    if version then
        window:Tag({
            Title = tostring(version),
            Icon = "tag",
            Color = Color3.fromHex("#17101D"),
            Border = true,
        })
    end

    if live ~= false then
        window:Tag({
            Title = statusTitle or "ALL SCRIPTS LIVE",
            Icon = "activity",
            Color = Color3.fromHex("#101A16"),
            Border = true,
        })
    end

    local app = createApp(window)

    task.defer(function()
        WindUI:Notify({
            Title = "XYNERIA",
            Content = "Interface loaded.",
            Icon = "sparkles",
            Duration = 2.5,
        })
    end)

    return app
end

return setmetatable({}, XyneriaUI)
