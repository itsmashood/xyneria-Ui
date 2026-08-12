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
