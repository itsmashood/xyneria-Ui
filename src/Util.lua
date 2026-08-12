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
