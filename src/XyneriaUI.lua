local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local Window = require(script.Parent.Window)

local XyneriaUI = {}
XyneriaUI.__index = XyneriaUI
XyneriaUI.Version = "3.0.0"
XyneriaUI.StyleVersion = "3.0.0"

local activeTheme = Theme.Name
local notificationGui
local notificationHolder

local function ensureNotificationHost()
    if notificationGui and notificationGui.Parent then return notificationHolder end
    notificationGui = Util.new("ScreenGui", {
        Name = "XyneriaNotifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, Util.getGuiParent())
    notificationHolder = Util.new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(330, 520),
    }, notificationGui)
    Util.new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, notificationHolder)
    return notificationHolder
end

local function notify(title, content, icon, duration)
    local holder = ensureNotificationHost()
    local card = Util.new("Frame", {
        BackgroundColor3 = Theme.PanelAlt,
        BackgroundTransparency = .04,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 74),
    }, holder)
    Util.corner(card, 11)
    Util.stroke(card, Theme.Outline, .25, 1)
    local rail = Util.new("Frame", {BackgroundColor3=Theme.Primary,BorderSizePixel=0,Size=UDim2.new(0,3,1,-18),Position=UDim2.fromOffset(0,9)},card)
    Util.corner(rail,999); Theme.gradient(rail,Theme.Purple,Theme.Pink,90)
    Util.new("TextLabel", {
        BackgroundTransparency=1,Position=UDim2.fromOffset(14,10),Size=UDim2.new(1,-28,0,22),
        Font=Enum.Font.GothamBold,Text=tostring(title or "XYNERIA"),TextColor3=Theme.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
    },card)
    Util.new("TextLabel", {
        BackgroundTransparency=1,Position=UDim2.fromOffset(14,34),Size=UDim2.new(1,-28,0,28),
        Font=Enum.Font.Gotham,Text=tostring(content or ""),TextColor3=Theme.MutedText,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    },card)
    card.BackgroundTransparency = 1
    Util.tween(card,.18,{BackgroundTransparency=.04})
    task.delay(tonumber(duration) or 4, function()
        if card and card.Parent then
            Util.tween(card,.18,{BackgroundTransparency=1})
            task.delay(.2,function() if card and card.Parent then card:Destroy() end end)
        end
    end)
    return card
end

function XyneriaUI:GetCore()
    return self
end

function XyneriaUI:GetStyle()
    return {
        Name = Theme.Name,
        Version = self.StyleVersion,
        Theme = Theme,
    }
end

function XyneriaUI:SetTheme(name)
    if name ~= nil and tostring(name) ~= Theme.Name then
        return false, "Only the built-in Xyneria theme is available in this package."
    end
    activeTheme = Theme.Name
    return true
end

function XyneriaUI:Notify(title, content, icon, duration)
    return notify(title, content, icon, duration)
end

function XyneriaUI:CreateWindow(options)
    options = options or {}
    local defaults = {
        Title = "XYNERIA",
        Author = "EXPLOIT WITH CONFIDENCE.",
        Folder = "Xyneria",
        Size = UDim2.fromOffset(720, 470),
        SideBarWidth = 178,
        ToggleKey = Enum.KeyCode.RightShift,
        Effects = true,
        Motion = true,
        Live = true,
    }
    local config = {}
    for k,v in pairs(defaults) do config[k]=v end
    for k,v in pairs(options) do config[k]=v end

    local window = Window.new(config, notify)
    if config.Version then
        window:Tag({Title=tostring(config.Version), Color=Theme.Surface, Border=true})
    end
    if config.Live ~= false then
        window:Tag({Title=tostring(config.StatusTitle or "ALL SCRIPTS LIVE"), Color=Color3.fromHex("#101A16"), Border=true})
    end

    local app = {
        Window = window,
        Core = self,
        Style = Theme,
    }

    function app:Tab(c) return self.Window:Tab(c) end
    function app:Section(c) return self.Window:Section(c) end
    function app:Divider() return self.Window:Divider() end
    function app:SelectTab(tab) return self.Window:SelectTab(tab) end
    function app:Notify(title, content, icon, duration) return notify(title, content, icon, duration) end
    function app:Dialog(c) return self.Window:Dialog(c) end
    function app:Open() return self.Window:Open() end
    function app:Close() return self.Window:Close() end
    function app:Toggle() return self.Window:Toggle() end
    function app:Destroy() return self.Window:Destroy() end
    function app:SetTitle(v) return self.Window:SetTitle(v) end
    function app:SetAuthor(v) return self.Window:SetAuthor(v) end
    function app:SetScale(v) return self.Window:SetUIScale(v) end
    function app:SetEffects(v) return self.Window:SetEffects(v) end
    function app:Pulse() return self.Window:Pulse() end
    function app:GetStyle() return {Name=Theme.Name,Version=XyneriaUI.StyleVersion,Effects=self.Window.Effects,Theme=activeTheme} end
    function app:SaveConfig(name)
        local ok, a, b = pcall(function() return self.Window.ConfigManager:Config(name or "default"):Save() end)
        if not ok then return false, a end
        return a, b
    end
    function app:LoadConfig(name)
        local ok, a, b = pcall(function() return self.Window.ConfigManager:Config(name or "default"):Load() end)
        if not ok then return false, a end
        return a, b
    end

    task.defer(function() notify("XYNERIA", "Arc interface loaded.", "sparkles", 2.5) end)
    return app
end

return setmetatable({}, XyneriaUI)
