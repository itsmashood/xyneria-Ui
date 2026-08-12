local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local ConfigManager = require(script.Parent.Config)
local Controls = require(script.Parent.Controls)

local Window = {}
Window.__index = Window

local function scrollingPage(parent)
    local page = Util.new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Primary,
        Visible = false,
    }, parent)
    Util.padding(page, 10, 10, 10, 12)
    Util.new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    return page
end

local function makeText(parent, props)
    local defaults = {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }
    for k, v in pairs(props or {}) do defaults[k] = v end
    return Util.new("TextLabel", defaults, parent)
end

function Window.new(options, notifier)
    options = options or {}
    local self = setmetatable({}, Window)
    self.Options = options
    self.Notifier = notifier
    self.Tabs = {}
    self.Tags = {}
    self.Visible = true
    self.Destroyed = false
    self.Effects = options.Effects ~= false
    self.Motion = options.Motion ~= false
    self.ConfigManager = ConfigManager.new(options.Folder or "Xyneria")
    self.Scale = 1

    local gui = Util.new("ScreenGui", {
        Name = "XyneriaUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, Util.getGuiParent())
    self.Gui = gui

    local width = 720
    local height = 470
    if typeof(options.Size) == "UDim2" then
        width = options.Size.X.Offset > 0 and options.Size.X.Offset or width
        height = options.Size.Y.Offset > 0 and options.Size.Y.Offset or height
    end

    local shadow = Util.new("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width + 18, height + 18),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, gui)
    Util.corner(shadow, 20)
    self.Shadow = shadow

    local main = Util.new("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    Util.corner(main, options.Radius or 15)
    Util.stroke(main, Theme.Outline, 0.18, 1)
    Theme.gradient(main, Theme.Background, Theme.BackgroundSecondary, 115)
    self.Main = main

    local scale = Util.new("UIScale", { Scale = 1 }, main)
    self.UIScale = scale

    if self.Effects then
        local glow = Util.new("Frame", {
            Name = "Glow",
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 0.86,
            BorderSizePixel = 0,
            Position = UDim2.new(0.58, 0, -0.15, 0),
            Size = UDim2.new(0.55, 0, 0.55, 0),
            ZIndex = 0,
        }, main)
        Util.corner(glow, 999)
        Theme.gradient(glow, Theme.Purple, Theme.Pink, 35)
        self.Glow = glow
    end

    local sidebarWidth = tonumber(options.SideBarWidth) or 178
    local sidebar = Util.new("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.PanelAlt,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        ZIndex = 2,
    }, main)
    self.Sidebar = sidebar

    local rail = Util.new("Frame", {
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -24),
        Position = UDim2.fromOffset(0, 12),
        ZIndex = 4,
    }, sidebar)
    Util.corner(rail, 999)
    Theme.gradient(rail, Theme.Purple, Theme.Pink, 90)

    local brand = makeText(sidebar, {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.new(1, -32, 0, 24),
        Font = Enum.Font.GothamBlack,
        Text = tostring(options.Title or "XYNERIA"),
        TextColor3 = Theme.Text,
        TextSize = 17,
    })
    self.TitleLabel = brand

    local author = makeText(sidebar, {
        Position = UDim2.fromOffset(16, 37),
        Size = UDim2.new(1, -32, 0, 18),
        Font = Enum.Font.GothamMedium,
        Text = tostring(options.Author or "EXPLOIT WITH CONFIDENCE."),
        TextColor3 = Theme.MutedText,
        TextSize = 9,
    })
    self.AuthorLabel = author

    local tags = Util.new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 61),
        Size = UDim2.new(1, -28, 0, 28),
    }, sidebar)
    Util.new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tags)
    self.TagHolder = tags

    local tabScroll = Util.new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 96),
        Size = UDim2.new(1, -20, 1, -110),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
    }, sidebar)
    Util.new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tabScroll)
    self.TabScroll = tabScroll

    local topbar = Util.new("Frame", {
        Name = "Topbar",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 0, 50),
        ZIndex = 3,
    }, main)
    self.Topbar = topbar

    local pageTitle = makeText(topbar, {
        Position = UDim2.fromOffset(18, 13),
        Size = UDim2.new(1, -100, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "HOME",
        TextSize = 13,
    })
    self.PageTitle = pageTitle

    local close = Util.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.MutedText,
        TextSize = 16,
    }, topbar)
    Util.corner(close, 8)
    close.MouseEnter:Connect(function() Util.tween(close, .12, {BackgroundColor3=Theme.Danger, TextColor3=Theme.Text}) end)
    close.MouseLeave:Connect(function() Util.tween(close, .12, {BackgroundColor3=Theme.Surface, TextColor3=Theme.MutedText}) end)
    close.MouseButton1Click:Connect(function() self:Close() end)

    local separator = Util.new("Frame", {
        BackgroundColor3 = Theme.Outline,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(0, sidebarWidth + 12, 0, 49),
        Size = UDim2.new(1, -sidebarWidth - 24, 0, 1),
        ZIndex = 3,
    }, main)
    Theme.gradient(separator, Theme.Purple, Theme.Pink, 0)

    local content = Util.new("Frame", {
        Name = "Content",
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        Position = UDim2.new(0, sidebarWidth + 10, 0, 58),
        Size = UDim2.new(1, -sidebarWidth - 20, 1, -68),
        ClipsDescendants = true,
    }, main)
    Util.corner(content, 11)
    Util.stroke(content, Theme.Outline, 0.5, 1)
    self.Content = content

    self.Connections = Util.makeDraggable(topbar, main)
    self.Connections[#self.Connections + 1] = main:GetPropertyChangedSignal("Position"):Connect(function()
        shadow.Position = main.Position
    end)

    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    self.Connections[#self.Connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            self:Toggle()
        end
    end)

    return self
end

function Window:Tab(config)
    config = config or {}
    local tab = {
        Window = self,
        Title = tostring(config.Title or "Tab"),
        Selected = false,
        __type = "Tab",
    }

    local button = Util.new("TextButton", {
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.42,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        AutoButtonColor = false,
        Font = Enum.Font.GothamSemibold,
        Text = "  " .. tab.Title,
        TextColor3 = Theme.MutedText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.TabScroll)
    Util.corner(button, 8)
    local stroke = Util.stroke(button, Theme.Outline, 0.72, 1)
    local blade = Util.new("Frame", {
        AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.new(0, 3, .5, 0),
        Size = UDim2.new(0, 2, .45, 0),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = .8,
        BorderSizePixel = 0,
    }, button)
    Util.corner(blade, 999)
    Theme.gradient(blade, Theme.Purple, Theme.Pink, 90)

    local page = scrollingPage(self.Content)
    tab.Button = button
    tab.Page = page
    tab.UIElements = { Main = button, Page = page }
    Controls.attach(tab, page, { ConfigManager = self.ConfigManager, Window = self })

    function tab:Select()
        self.Window:SelectTab(self)
    end
    function tab:SetTitle(value)
        self.Title = tostring(value or "")
        self.Button.Text = "  " .. self.Title
        if self.Selected then self.Window.PageTitle.Text = string.upper(self.Title) end
        return self
    end

    button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    button.MouseEnter:Connect(function()
        if not tab.Selected then Util.tween(button, .12, {BackgroundTransparency=.22, TextColor3=Theme.Text}) end
    end)
    button.MouseLeave:Connect(function()
        if not tab.Selected then Util.tween(button, .12, {BackgroundTransparency=.42, TextColor3=Theme.MutedText}) end
    end)

    tab._stroke = stroke
    tab._blade = blade
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:Section(config)
    config = config or {}
    local section = {
        Window = self,
        Title = tostring(config.Title or "Section"),
        __type = "Section",
    }
    local label = makeText(self.TabScroll, {
        Size = UDim2.new(1, 0, 0, 24),
        Text = string.upper(section.Title),
        TextColor3 = Theme.MutedText,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
    })
    Util.padding(label, 7, 0, 0, 0)
    section.Label = label
    function section:Tab(tabConfig) return self.Window:Tab(tabConfig) end
    function section:Destroy() if self.Label then self.Label:Destroy() end end
    return section
end

function Window:Divider()
    local divider = Util.new("Frame", {
        BackgroundColor3 = Theme.Outline,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 0, 1),
    }, self.TabScroll)
    return divider
end

function Window:SelectTab(tab)
    if not tab then return false end
    for _, item in ipairs(self.Tabs) do
        local selected = item == tab
        item.Selected = selected
        item.Page.Visible = selected
        Util.tween(item.Button, .14, {
            BackgroundTransparency = selected and .12 or .42,
            TextColor3 = selected and Theme.Text or Theme.MutedText,
        })
        Util.tween(item._stroke, .14, { Transparency = selected and .3 or .72, Color = selected and Theme.Primary or Theme.Outline })
        Util.tween(item._blade, .14, { BackgroundTransparency = selected and 0 or .8, Size = selected and UDim2.new(0,3,.7,0) or UDim2.new(0,2,.45,0) })
    end
    self.SelectedTab = tab
    self.PageTitle.Text = string.upper(tab.Title)
    return true
end

function Window:Tag(config)
    config = config or {}
    local tag = Util.new("TextLabel", {
        BackgroundColor3 = config.Color or Theme.Surface,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(math.max(48, 12 + #tostring(config.Title or "TAG") * 6), 22),
        Font = Enum.Font.GothamBold,
        Text = tostring(config.Title or "TAG"),
        TextColor3 = Theme.Text,
        TextSize = 8,
    }, self.TagHolder)
    Util.corner(tag, 7)
    if config.Border ~= false then Util.stroke(tag, Theme.Outline, .45, 1) end
    table.insert(self.Tags, tag)
    return tag
end

function Window:Dialog(config)
    config = config or {}
    local overlay = Util.new("TextButton", {
        BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency=.35, BorderSizePixel=0,
        Size=UDim2.fromScale(1,1), Text="", AutoButtonColor=false, ZIndex=100,
    }, self.Main)
    local panel = Util.new("Frame", {
        AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(360,180),
        BackgroundColor3=Theme.PanelAlt, BorderSizePixel=0, ZIndex=101,
    }, overlay)
    Util.corner(panel,12); Util.stroke(panel,Theme.Outline,.18,1)
    makeText(panel,{Position=UDim2.fromOffset(18,16),Size=UDim2.new(1,-36,0,24),Font=Enum.Font.GothamBold,Text=tostring(config.Title or "Dialog"),TextSize=15,ZIndex=102})
    makeText(panel,{Position=UDim2.fromOffset(18,48),Size=UDim2.new(1,-36,0,60),Text=tostring(config.Content or config.Desc or ""),TextColor3=Theme.MutedText,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=102})
    local buttons = config.Buttons or {{Title="OK"}}
    local holder = Util.new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,18,1,-52),Size=UDim2.new(1,-36,0,34),ZIndex=102},panel)
    Util.new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,8)},holder)
    local dialog = { Frame=overlay }
    function dialog:Close() if overlay then overlay:Destroy() end end
    for _, data in ipairs(buttons) do
        local b=Util.new("TextButton",{BackgroundColor3=Theme.Surface,BorderSizePixel=0,Size=UDim2.fromOffset(90,32),Font=Enum.Font.GothamSemibold,Text=tostring(data.Title or "OK"),TextColor3=Theme.Text,TextSize=11,AutoButtonColor=false,ZIndex=103},holder)
        Util.corner(b,8)
        b.MouseButton1Click:Connect(function() Util.callback(data.Callback); dialog:Close() end)
    end
    overlay.MouseButton1Click:Connect(function() if config.Dismissible ~= false then dialog:Close() end end)
    return dialog
end

function Window:Open()
    if self.Destroyed then return false end
    self.Visible = true
    self.Main.Visible = true
    self.Shadow.Visible = true
    return true
end

function Window:Close()
    if self.Destroyed then return false end
    self.Visible = false
    self.Main.Visible = false
    self.Shadow.Visible = false
    return true
end

function Window:Toggle()
    if self.Visible then return self:Close() else return self:Open() end
end

function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, connection in ipairs(self.Connections or {}) do pcall(function() connection:Disconnect() end) end
    if self.Gui then self.Gui:Destroy() end
end

function Window:SetTitle(title)
    self.TitleLabel.Text = tostring(title or "")
    return self
end

function Window:SetAuthor(author)
    self.AuthorLabel.Text = tostring(author or "")
    return self
end

function Window:SetUIScale(scale)
    self.Scale = math.clamp(tonumber(scale) or 1, .5, 1.8)
    self.UIScale.Scale = self.Scale
    return self
end

function Window:SetEffects(enabled)
    self.Effects = enabled ~= false
    if self.Glow then self.Glow.Visible = self.Effects end
    return self
end

function Window:Pulse()
    if not self.Glow or not self.Glow.Parent then return false end
    self.Glow.BackgroundTransparency = .65
    Util.tween(self.Glow, .5, {BackgroundTransparency=.86}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    return true
end

return Window
