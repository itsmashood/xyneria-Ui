local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)

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
