--[[
    WindHub Toggle Control
    Simple on/off toggle switch for features
]]

local Toggle = {}

local TweenService = game:GetService("TweenService")

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

function Toggle.Create(parent, feature, layoutOrder, Theme, loadModule, LoadedModules, FeatureElements)
    local featureModule = loadModule(feature.Module)
    if featureModule then
        LoadedModules[feature.Name] = featureModule
    end
    
    local toggle = Instance.new("Frame")
    toggle.Name = feature.Name
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
    titleLabel.Text = feature.Name
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
    descLabel.Text = feature.Description
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
        
        if featureModule and featureModule.Toggle then
            featureModule:Toggle(isEnabled)
        end
    end)
    
    FeatureElements[feature.Name] = {
        Frame = toggle,
        Switch = switchBg,
        Knob = switchKnob,
        Module = featureModule,
    }
    
    return toggle
end

return Toggle
