--[[
    WindHub Features Tab
    Feature toggles and controls
]]

local FeaturesTab = {}
FeaturesTab.__index = FeaturesTab

local TweenService = game:GetService("TweenService")

local Theme = nil
local Container = nil

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

local function createToggle(parent, name, description, layoutOrder, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = name
    toggle.Size = UDim2.new(1, 0, 0, 60)
    toggle.BackgroundColor3 = Theme.Colors.Card
    toggle.LayoutOrder = layoutOrder
    toggle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = toggle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = toggle
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 0, 22)
    titleLabel.Position = UDim2.new(0, 16, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Theme.Colors.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Theme.Fonts.Subtitle
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggle
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -80, 0, 16)
    descLabel.Position = UDim2.new(0, 16, 0, 34)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Theme.Colors.TextMuted
    descLabel.TextSize = 11
    descLabel.Font = Theme.Fonts.Body
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = toggle
    
    local switchBg = Instance.new("TextButton")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 44, 0, 24)
    switchBg.Position = UDim2.new(1, -60, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Theme.Colors.Secondary
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = toggle
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    local switchKnob = Instance.new("Frame")
    switchKnob.Name = "Knob"
    switchKnob.Size = UDim2.new(0, 18, 0, 18)
    switchKnob.Position = UDim2.new(0, 3, 0.5, 0)
    switchKnob.AnchorPoint = Vector2.new(0, 0.5)
    switchKnob.BackgroundColor3 = Theme.Colors.TextMuted
    switchKnob.Parent = switchBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = switchKnob
    
    local isEnabled = false
    
    switchBg.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            createTween(switchBg, {BackgroundColor3 = Theme.Colors.Primary}, 0.2):Play()
            createTween(switchKnob, {Position = UDim2.new(1, -21, 0.5, 0), BackgroundColor3 = Theme.Colors.Text}, 0.2):Play()
        else
            createTween(switchBg, {BackgroundColor3 = Theme.Colors.Secondary}, 0.2):Play()
            createTween(switchKnob, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Theme.Colors.TextMuted}, 0.2):Play()
        end
        
        if callback then
            callback(isEnabled)
        end
    end)
    
    return toggle
end

function FeaturesTab:Create(parent, theme)
    Theme = theme
    
    Container = Instance.new("ScrollingFrame")
    Container.Name = "FeaturesTab"
    Container.Size = UDim2.new(1, -180, 1, -45)
    Container.Position = UDim2.new(0, 180, 0, 45)
    Container.BackgroundColor3 = Theme.Colors.Background
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Theme.Colors.Primary
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.Visible = false
    Container.Parent = parent
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = Container
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = Container
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = "⚡ Features"
    header.TextColor3 = Theme.Colors.Text
    header.TextSize = 16
    header.Font = Theme.Fonts.Title
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.Parent = Container
    
    createToggle(Container, "Example Feature", "This is a placeholder feature", 2, function(enabled)
        print("[WindHub] Example Feature:", enabled)
    end)
    
    createToggle(Container, "Coming Soon", "More features will be added here", 3, function(enabled)
        print("[WindHub] Coming Soon:", enabled)
    end)
    
    return Container
end

function FeaturesTab:Show()
    if Container then
        Container.Visible = true
    end
end

function FeaturesTab:Hide()
    if Container then
        Container.Visible = false
    end
end

function FeaturesTab:GetContainer()
    return Container
end

return FeaturesTab
