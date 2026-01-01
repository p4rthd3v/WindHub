--[[
    WindHub Slider Control
    Adjustable value slider for features
]]

local Slider = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

function Slider.Create(parent, feature, layoutOrder, Theme, loadModule, LoadedModules, FeatureElements)
    local featureModule = loadModule(feature.Module)
    if featureModule then
        LoadedModules[feature.Name] = featureModule
    end
    
    local slider = Instance.new("Frame")
    slider.Name = feature.Name
    slider.Size = UDim2.new(1, 0, 0, 85)
    slider.BackgroundColor3 = Theme.Colors.Card
    slider.LayoutOrder = layoutOrder
    slider.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = slider
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = slider
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 0, 22)
    titleLabel.Position = UDim2.new(0, 16, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = feature.Name
    titleLabel.TextColor3 = Theme.Colors.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Theme.Fonts.Subtitle
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 50, 0, 22)
    valueLabel.Position = UDim2.new(1, -66, 0, 10)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(feature.Default)
    valueLabel.TextColor3 = Theme.Colors.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Theme.Fonts.Title
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -32, 0, 14)
    descLabel.Position = UDim2.new(0, 16, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = feature.Description
    descLabel.TextColor3 = Theme.Colors.TextMuted
    descLabel.TextSize = 11
    descLabel.Font = Theme.Fonts.Body
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = slider
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, -32, 0, 8)
    sliderBg.Position = UDim2.new(0, 16, 0, 58)
    sliderBg.BackgroundColor3 = Theme.Colors.Secondary
    sliderBg.Parent = slider
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Colors.Primary
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundColor3 = Theme.Colors.Text
    sliderKnob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local currentValue = feature.Default
    local isDragging = false
    
    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        local value = math.floor(feature.Min + (feature.Max - feature.Min) * percent)
        currentValue = value
        
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
        
        if featureModule and featureModule.SetSpeed then
            featureModule:SetSpeed(value)
        end
    end
    
    local initialPercent = (feature.Default - feature.Min) / (feature.Max - feature.Min)
    updateSlider(initialPercent)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            
            if featureModule and featureModule.Enable then
                featureModule:Enable()
            end
            
            local percent = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(percent)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(percent)
        end
    end)
    
    FeatureElements[feature.Name] = {
        Frame = slider,
        Module = featureModule,
    }
    
    return slider
end

return Slider
