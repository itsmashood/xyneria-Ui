-- XyneriaUI standalone build
local __modules = {}
local __cache = {}
local __require

__modules["Theme"] = function()
local Theme = {
    Name = "Xyneria",
    Background = Color3.fromHex("#050308"),
    BackgroundSecondary = Color3.fromHex("#110718"),
    Panel = Color3.fromHex("#120A18"),
    PanelAlt = Color3.fromHex("#0D0712"),
    Surface = Color3.fromHex("#17101D"),
    SurfaceHover = Color3.fromHex("#21132B"),
    Outline = Color3.fromHex("#3C2449"),
    Text = Color3.fromHex("#F9F4FC"),
    MutedText = Color3.fromHex("#8D7F98"),
    Purple = Color3.fromHex("#7957FF"),
    Pink = Color3.fromHex("#FF4FCB"),
    Primary = Color3.fromHex("#D85DFF"),
    Success = Color3.fromHex("#5DE2A5"),
    Danger = Color3.fromHex("#FF5D7A"),
}

function Theme.gradient(parent, a, b, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a or Theme.Purple),
        ColorSequenceKeypoint.new(1, b or Theme.Pink),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

return Theme

end

__modules["Util"] = function()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Util = {}

function Util.safe(callback, ...)
    local args = table.pack(...)
    local ok, result = pcall(function()
        return callback(table.unpack(args, 1, args.n))
    end)
    return ok, result
end

function Util.new(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        pcall(function()
            object[key] = value
        end)
    end
    object.Parent = parent
    return object
end

function Util.corner(parent, radius)
    return Util.new("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

function Util.stroke(parent, color, transparency, thickness)
    return Util.new("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

function Util.padding(parent, left, right, top, bottom)
    return Util.new("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
    }, parent)
end

function Util.tween(instance, duration, props, style, direction)
    if not instance or not instance.Parent then
        return nil
    end
    local ok, tween = pcall(function()
        return TweenService:Create(
            instance,
            TweenInfo.new(duration or 0.16, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
            props
        )
    end)
    if ok and tween then
        tween:Play()
        return tween
    end
    return nil
end

function Util.callback(callback, ...)
    if type(callback) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not ok then
            warn("[XyneriaUI] callback error: " .. tostring(err))
        end
    end)
end

function Util.getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        return coreGui
    end

    local player = Players.LocalPlayer
    if player then
        return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
    end

    error("XyneriaUI could not find a GUI parent")
end

function Util.makeDraggable(handle, target)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart
    local startPosition
    local dragInput
    local connections = {}

    connections[#connections + 1] = handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    connections[#connections + 1] = handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    return connections
end

function Util.hex(color)
    return string.format("#%02X%02X%02X", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
end

function Util.fromHex(value, fallback)
    if typeof(value) == "Color3" then
        return value
    end
    if type(value) == "string" then
        local ok, color = pcall(Color3.fromHex, value)
        if ok then
            return color
        end
    end
    return fallback or Color3.new(1, 1, 1)
end

return Util

end

__modules["Config"] = function()
local HttpService = game:GetService("HttpService")
local Util = __require("Util")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local Config = {}
Config.__index = Config

local function available(name)
    return type(getgenv) == "function" and type(getgenv()[name]) == "function" or type(_G[name]) == "function"
end

local function fn(name)
    if type(getgenv) == "function" then
        local env = getgenv()
        if type(env[name]) == "function" then
            return env[name]
        end
    end
    return _G[name]
end

function ConfigManager.new(folder)
    return setmetatable({
        Folder = folder or "Xyneria",
        Entries = {},
    }, ConfigManager)
end

function ConfigManager:Register(flag, getter, setter)
    if type(flag) ~= "string" or flag == "" then
        return
    end
    self.Entries[flag] = { Get = getter, Set = setter }
end

function ConfigManager:Config(name)
    return setmetatable({ Manager = self, Name = tostring(name or "default") }, Config)
end

function Config:_path()
    return self.Manager.Folder .. "/" .. self.Name .. ".json"
end

function Config:Save()
    if not (available("writefile") and available("makefolder")) then
        return false, "filesystem API is unavailable"
    end

    local data = {}
    for flag, entry in pairs(self.Manager.Entries) do
        local ok, value = pcall(entry.Get)
        if ok then
            if typeof(value) == "Color3" then
                value = { __type = "Color3", value = Util.hex(value) }
            elseif typeof(value) == "EnumItem" then
                value = { __type = "EnumItem", value = value.Name }
            end
            data[flag] = value
        end
    end

    pcall(fn("makefolder"), self.Manager.Folder)
    local encoded = HttpService:JSONEncode(data)
    fn("writefile")(self:_path(), encoded)
    return true
end

function Config:Load()
    if not (available("readfile") and available("isfile")) then
        return false, "filesystem API is unavailable"
    end

    local path = self:_path()
    if not fn("isfile")(path) then
        return false, "config does not exist"
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(fn("readfile")(path))
    end)
    if not ok or type(decoded) ~= "table" then
        return false, "invalid config"
    end

    for flag, value in pairs(decoded) do
        local entry = self.Manager.Entries[flag]
        if entry and type(entry.Set) == "function" then
            if type(value) == "table" and value.__type == "Color3" then
                value = Util.fromHex(value.value)
            end
            pcall(entry.Set, value)
        end
    end

    return true
end

return ConfigManager

end

__modules["Controls"] = function()
local UserInputService = game:GetService("UserInputService")
local Theme = __require("Theme")
local Util = __require("Util")

local Controls = {}

local function baseCard(container, height)
    local card = Util.new("Frame", {
        BackgroundColor3 = Theme.PanelAlt,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 52),
        AutomaticSize = Enum.AutomaticSize.None,
    }, container)
    Util.corner(card, 10)
    Util.stroke(card, Theme.Outline, 0.45, 1)
    return card
end

local function titleLabel(parent, title, y, width)
    return Util.new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, y or 0),
        Size = UDim2.new(1, width or -28, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(title or ""),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function descLabel(parent, desc, y, width)
    return Util.new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, y or 22),
        Size = UDim2.new(1, width or -28, 0, 18),
        Font = Enum.Font.Gotham,
        Text = tostring(desc or ""),
        TextColor3 = Theme.MutedText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function commonObject(kind, frame, config)
    local object = {
        __type = kind,
        Frame = frame,
        ElementFrame = frame,
        Config = config or {},
    }
    function object:SetVisible(value)
        frame.Visible = value ~= false
        return self
    end
    function object:Destroy()
        if frame then frame:Destroy() end
    end
    return object
end

local function registerFlag(context, config, object)
    if context.ConfigManager and config and config.Flag and type(object.Get) == "function" and type(object.Set) == "function" then
        context.ConfigManager:Register(config.Flag, function()
            return object:Get()
        end, function(value)
            object:Set(value)
        end)
    end
end

function Controls.attach(containerObject, contentFrame, context)
    local function paragraph(config)
        config = config or {}
        local frame = baseCard(contentFrame, 58)
        local title = titleLabel(frame, config.Title or "Paragraph", 8)
        local desc = descLabel(frame, config.Desc or config.Content or "", 30)
        local object = commonObject("Paragraph", frame, config)
        function object:SetTitle(value) title.Text = tostring(value or "") end
        function object:SetDesc(value) desc.Text = tostring(value or "") end
        return object
    end

    local function button(config)
        config = config or {}
        local frame = baseCard(contentFrame, 52)
        local title = titleLabel(frame, config.Title or "Button", 15, -56)
        local action = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(28, 28),
            Font = Enum.Font.GothamBold,
            Text = ">",
            TextColor3 = Theme.Primary,
            TextSize = 16,
        }, frame)
        local hit = Util.new("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            AutoButtonColor = false,
        }, frame)
        hit.MouseEnter:Connect(function() Util.tween(frame, 0.12, { BackgroundColor3 = Theme.SurfaceHover }) end)
        hit.MouseLeave:Connect(function() Util.tween(frame, 0.12, { BackgroundColor3 = Theme.PanelAlt }) end)
        hit.MouseButton1Click:Connect(function()
            Util.tween(action, 0.08, { TextColor3 = Theme.Pink })
            task.delay(0.12, function() if action.Parent then Util.tween(action, 0.1, { TextColor3 = Theme.Primary }) end end)
            Util.callback(config.Callback)
        end)
        local object = commonObject("Button", frame, config)
        function object:Fire() Util.callback(config.Callback) end
        function object:SetTitle(value) title.Text = tostring(value or "") end
        return object
    end

    local function toggle(config)
        config = config or {}
        local frame = baseCard(contentFrame, 58)
        local title = titleLabel(frame, config.Title or "Toggle", config.Desc and 8 or 18, -80)
        if config.Desc then descLabel(frame, config.Desc, 31, -80) end
        local track = Util.new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(44, 24),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
        }, frame)
        Util.corner(track, 999)
        local knob = Util.new("Frame", {
            Position = UDim2.fromOffset(3, 3),
            Size = UDim2.fromOffset(18, 18),
            BackgroundColor3 = Theme.MutedText,
            BorderSizePixel = 0,
        }, track)
        Util.corner(knob, 999)
        local hit = Util.new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = "", AutoButtonColor = false }, frame)
        local value = config.Value == true
        local object = commonObject("Toggle", frame, config)
        local function render(instant)
            local propsTrack = { BackgroundColor3 = value and Theme.Purple or Theme.Surface }
            local propsKnob = { Position = value and UDim2.new(1, -21, 0, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = value and Theme.Text or Theme.MutedText }
            if instant then
                for k,v in pairs(propsTrack) do track[k] = v end
                for k,v in pairs(propsKnob) do knob[k] = v end
            else
                Util.tween(track, 0.14, propsTrack)
                Util.tween(knob, 0.14, propsKnob)
            end
        end
        function object:Set(newValue, silent)
            value = newValue == true
            render(false)
            if not silent then Util.callback(config.Callback, value) end
            return self
        end
        function object:Get() return value end
        function object:SetTitle(newTitle) title.Text = tostring(newTitle or "") end
        hit.MouseButton1Click:Connect(function() object:Set(not value) end)
        render(true)
        registerFlag(context, config, object)
        return object
    end

    local function slider(config)
        config = config or {}
        local min = tonumber(config.Min) or 0
        local max = tonumber(config.Max) or 100
        if max <= min then max = min + 1 end
        local step = tonumber(config.Step) or 1
        local value = math.clamp(tonumber(config.Value) or min, min, max)
        local frame = baseCard(contentFrame, 72)
        local title = titleLabel(frame, config.Title or "Slider", 8, -88)
        local valueLabel = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, 8),
            Size = UDim2.fromOffset(72, 22),
            Font = Enum.Font.GothamSemibold,
            TextColor3 = Theme.Primary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, frame)
        local track = Util.new("Frame", {
            Position = UDim2.new(0, 14, 1, -22),
            Size = UDim2.new(1, -28, 0, 6),
            BackgroundColor3 = Theme.Outline,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
        }, frame)
        Util.corner(track, 999)
        local fill = Util.new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Theme.Primary, BorderSizePixel = 0 }, track)
        Util.corner(fill, 999)
        Theme.gradient(fill, Theme.Purple, Theme.Pink, 0)
        local knob = Util.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.fromOffset(14,14),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
        }, track)
        Util.corner(knob, 999)
        local hit = Util.new("TextButton", { BackgroundTransparency = 1, Position = UDim2.new(0,0,0,-8), Size = UDim2.new(1,0,1,16), Text = "", AutoButtonColor = false }, track)
        local dragging = false
        local object = commonObject("Slider", frame, config)
        local function snap(v)
            local n = math.floor(((v - min) / step) + 0.5) * step + min
            return math.clamp(n, min, max)
        end
        local function render()
            local alpha = (value - min) / (max - min)
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.fromScale(alpha, 0.5)
            valueLabel.Text = tostring(value) .. (config.Suffix or "")
        end
        function object:Set(newValue, silent)
            value = snap(tonumber(newValue) or min)
            render()
            if not silent then Util.callback(config.Callback, value) end
            return self
        end
        function object:Get() return value end
        local function fromInput(input)
            local x = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local alpha = track.AbsoluteSize.X > 0 and x / track.AbsoluteSize.X or 0
            object:Set(min + (max - min) * alpha)
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; fromInput(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then fromInput(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        render()
        registerFlag(context, config, object)
        return object
    end

    local function progressBar(config)
        config = config or {}
        local frame = baseCard(contentFrame, 68)
        local title = titleLabel(frame, config.Title or "Progress", 8, -72)
        local label = Util.new("TextLabel", { BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-14,0,8), Size=UDim2.fromOffset(58,22), Font=Enum.Font.GothamSemibold, TextColor3=Theme.Primary, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right }, frame)
        local track = Util.new("Frame", { Position=UDim2.new(0,14,1,-20), Size=UDim2.new(1,-28,0,6), BackgroundColor3=Theme.Outline, BackgroundTransparency=.45, BorderSizePixel=0 }, frame)
        Util.corner(track,999)
        local fill = Util.new("Frame", { Size=UDim2.fromScale(0,1), BackgroundColor3=Theme.Primary, BorderSizePixel=0 }, track)
        Util.corner(fill,999); Theme.gradient(fill,Theme.Purple,Theme.Pink,0)
        local value = tonumber(config.Value) or 0
        local object = commonObject("ProgressBar", frame, config)
        function object:Set(v)
            value = math.clamp(tonumber(v) or 0,0,100)
            Util.tween(fill,.15,{Size=UDim2.fromScale(value/100,1)})
            label.Text = string.format("%d%%", math.floor(value + .5))
            return self
        end
        function object:Get() return value end
        object:Set(value)
        return object
    end

    local function inputBox(config)
        config = config or {}
        local frame = baseCard(contentFrame, 72)
        local title = titleLabel(frame, config.Title or "Input", 7)
        local box = Util.new("TextBox", {
            Position = UDim2.new(0, 14, 0, 33), Size = UDim2.new(1, -28, 0, 28),
            BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, ClearTextOnFocus = false,
            Font = Enum.Font.Gotham, Text = tostring(config.Value or ""), PlaceholderText = tostring(config.Placeholder or ""),
            TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        }, frame)
        Util.corner(box, 7); Util.padding(box, 10, 10, 0, 0)
        local object = commonObject("Input", frame, config)
        function object:Set(v, silent) box.Text = tostring(v or ""); if not silent then Util.callback(config.Callback, box.Text) end; return self end
        function object:Get() return box.Text end
        box.FocusLost:Connect(function(enterPressed) if config.Callback then Util.callback(config.Callback, box.Text, enterPressed) end end)
        registerFlag(context, config, object)
        return object
    end

    local function dropdown(config)
        config = config or {}
        local values = config.Values or config.Options or {}
        local selected = config.Value
        if selected == nil and #values > 0 then selected = values[1] end
        local frame = baseCard(contentFrame, 58)
        local title = titleLabel(frame, config.Title or "Dropdown", 18, -170)
        local buttonFrame = Util.new("TextButton", {
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-14,.5,0), Size=UDim2.fromOffset(140,30),
            BackgroundColor3=Theme.Surface, BorderSizePixel=0, AutoButtonColor=false,
            Font=Enum.Font.Gotham, TextColor3=Theme.Text, TextSize=11, TextTruncate=Enum.TextTruncate.AtEnd,
        }, frame)
        Util.corner(buttonFrame,7); Util.stroke(buttonFrame,Theme.Outline,.45,1)
        local menu
        local object = commonObject("Dropdown", frame, config)
        local function textValue(v)
            if type(v) == "table" then return table.concat(v, ", ") end
            return tostring(v or "Select")
        end
        local function closeMenu() if menu then menu:Destroy(); menu=nil end end
        local function rebuild()
            closeMenu()
            menu = Util.new("Frame", { BackgroundColor3=Theme.PanelAlt, BorderSizePixel=0, Position=UDim2.new(0,0,1,6), Size=UDim2.new(1,0,0,math.min(#values,6)*30+8), ZIndex=50 }, buttonFrame)
            Util.corner(menu,8); Util.stroke(menu,Theme.Outline,.25,1); Util.padding(menu,4,4,4,4)
            local layout = Util.new("UIListLayout", { Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder }, menu)
            for _, option in ipairs(values) do
                local item = Util.new("TextButton", { BackgroundColor3=Theme.Surface, BackgroundTransparency=.2, BorderSizePixel=0, Size=UDim2.new(1,0,0,28), ZIndex=51, AutoButtonColor=false, Font=Enum.Font.Gotham, Text=tostring(option), TextColor3=Theme.Text, TextSize=11 }, menu)
                Util.corner(item,6)
                item.MouseButton1Click:Connect(function() object:Set(option); closeMenu() end)
            end
        end
        function object:Set(v, silent) selected=v; buttonFrame.Text=textValue(selected); if not silent then Util.callback(config.Callback, selected) end; return self end
        function object:Get() return selected end
        function object:Refresh(newValues) values=newValues or {}; closeMenu(); return self end
        buttonFrame.MouseButton1Click:Connect(function() if menu then closeMenu() else rebuild() end end)
        buttonFrame.Text = textValue(selected)
        registerFlag(context, config, object)
        return object
    end

    local function keybind(config)
        config = config or {}
        local frame = baseCard(contentFrame, 56)
        local title = titleLabel(frame, config.Title or "Keybind", 17, -120)
        local key = config.Value or config.Key or Enum.KeyCode.RightShift
        local listening = false
        local keyButton = Util.new("TextButton", { AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-14,.5,0), Size=UDim2.fromOffset(90,30), BackgroundColor3=Theme.Surface, BorderSizePixel=0, AutoButtonColor=false, Font=Enum.Font.GothamSemibold, TextColor3=Theme.Primary, TextSize=11 }, frame)
        Util.corner(keyButton,7)
        local object = commonObject("Keybind", frame, config)
        local function render() keyButton.Text = listening and "..." or (typeof(key)=="EnumItem" and key.Name or tostring(key)) end
        function object:Set(v, silent) key=v; render(); if not silent then Util.callback(config.ChangedCallback, key) end; return self end
        function object:Get() return key end
        keyButton.MouseButton1Click:Connect(function() listening=true; render() end)
        UserInputService.InputBegan:Connect(function(input, processed)
            if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                listening=false; object:Set(input.KeyCode); return
            end
            if not processed and input.KeyCode == key then Util.callback(config.Callback) end
        end)
        render(); registerFlag(context, config, object)
        return object
    end

    local function colorpicker(config)
        config = config or {}
        local value = Util.fromHex(config.Value, Theme.Primary)
        local frame = baseCard(contentFrame, 56)
        local title = titleLabel(frame, config.Title or "Color", 17, -118)
        local hexBox = Util.new("TextBox", { AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-46,.5,0), Size=UDim2.fromOffset(82,28), BackgroundColor3=Theme.Surface, BorderSizePixel=0, ClearTextOnFocus=false, Font=Enum.Font.Code, Text=Util.hex(value), TextColor3=Theme.Text, TextSize=11 }, frame)
        Util.corner(hexBox,7)
        local swatch = Util.new("Frame", { AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-14,.5,0), Size=UDim2.fromOffset(24,24), BackgroundColor3=value, BorderSizePixel=0 }, frame)
        Util.corner(swatch,6); Util.stroke(swatch,Theme.Outline,.2,1)
        local object = commonObject("Colorpicker", frame, config)
        function object:Set(v, silent) value=Util.fromHex(v,value); swatch.BackgroundColor3=value; hexBox.Text=Util.hex(value); if not silent then Util.callback(config.Callback,value) end; return self end
        function object:Get() return value end
        hexBox.FocusLost:Connect(function() object:Set(hexBox.Text) end)
        registerFlag(context, config, object)
        return object
    end

    local function divider()
        local frame = Util.new("Frame", { BackgroundColor3=Theme.Outline, BackgroundTransparency=.55, BorderSizePixel=0, Size=UDim2.new(1,0,0,1) }, contentFrame)
        Theme.gradient(frame,Theme.Purple,Theme.Pink,0)
        return commonObject("Divider", frame, {})
    end

    local function space(config)
        local h = type(config)=="number" and config or ((config or {}).Size or 10)
        local frame = Util.new("Frame", { BackgroundTransparency=1, Size=UDim2.new(1,0,0,h) }, contentFrame)
        return commonObject("Space", frame, config or {})
    end

    local function code(config)
        config=config or {}
        local text=tostring(config.Code or config.Content or "")
        local lines=math.max(2, math.min(14, select(2,text:gsub("\n","\n"))+1))
        local frame=baseCard(contentFrame, lines*17+34)
        local label=Util.new("TextLabel", { BackgroundTransparency=1, Position=UDim2.new(0,12,0,10), Size=UDim2.new(1,-24,1,-20), Font=Enum.Font.Code, Text=text, TextColor3=Theme.Text, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=false }, frame)
        local object=commonObject("Code",frame,config)
        function object:Set(v) label.Text=tostring(v or "") end
        function object:Get() return label.Text end
        return object
    end

    local function image(config)
        config=config or {}
        local frame=baseCard(contentFrame, tonumber(config.Height) or 160)
        local img=Util.new("ImageLabel", { BackgroundTransparency=1, Position=UDim2.fromOffset(8,8), Size=UDim2.new(1,-16,1,-16), Image=tostring(config.Image or ""), ScaleType=Enum.ScaleType.Fit }, frame)
        local object=commonObject("Image",frame,config)
        function object:Set(v) img.Image=tostring(v or "") end
        function object:Get() return img.Image end
        return object
    end

    local function section(config)
        config=config or {}
        local holder=Util.new("Frame", { BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y }, contentFrame)
        local heading=Util.new("TextLabel", { BackgroundTransparency=1, Size=UDim2.new(1,0,0,28), Font=Enum.Font.GothamBold, Text=tostring(config.Title or "Section"), TextColor3=Theme.Primary, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left }, holder)
        local inner=Util.new("Frame", { BackgroundTransparency=1, Position=UDim2.fromOffset(0,30), Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y }, holder)
        Util.new("UIListLayout", { Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, inner)
        local object=commonObject("Section",holder,config)
        Controls.attach(object,inner,context)
        function object:SetTitle(v) heading.Text=tostring(v or "") end
        return object
    end

    containerObject.Paragraph = function(_, config) return paragraph(config) end
    containerObject.Button = function(_, config) return button(config) end
    containerObject.Toggle = function(_, config) return toggle(config) end
    containerObject.Slider = function(_, config) return slider(config) end
    containerObject.ProgressBar = function(_, config) return progressBar(config) end
    containerObject.Keybind = function(_, config) return keybind(config) end
    containerObject.Input = function(_, config) return inputBox(config) end
    containerObject.Dropdown = function(_, config) return dropdown(config) end
    containerObject.Code = function(_, config) return code(config) end
    containerObject.Colorpicker = function(_, config) return colorpicker(config) end
    containerObject.Section = function(_, config) return section(config) end
    containerObject.Divider = function(_) return divider() end
    containerObject.Space = function(_, config) return space(config) end
    containerObject.Image = function(_, config) return image(config) end
    containerObject.Group = function(_, config) return section(config) end
    containerObject.VStack = function(_, config) return section(config) end
    containerObject.HStack = function(_, config) return section(config) end
    containerObject.Viewport = function(_, config) return paragraph({Title=(config or {}).Title or "Viewport", Desc="Viewport placeholder"}) end
end

return Controls

end

__modules["Window"] = function()
local UserInputService = game:GetService("UserInputService")
local Theme = __require("Theme")
local Util = __require("Util")
local ConfigManager = __require("Config")
local Controls = __require("Controls")

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

end

__modules["XyneriaUI"] = function()
local Theme = __require("Theme")
local Util = __require("Util")
local Window = __require("Window")

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
        window:Tag({Title=tostring(config.StatusTitle or "FUCK ANTICHEAT"), Color=Color3.fromHex("#101A16"), Border=true})
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

end

__require = function(name)
    if __cache[name] ~= nil then
        return __cache[name]
    end
    local loader = __modules[name]
    assert(loader, "Unknown XyneriaUI module: " .. tostring(name))
    local value = loader()
    __cache[name] = value
    return value
end

return __require("XyneriaUI")
