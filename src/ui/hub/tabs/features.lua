--[[
    WindHub Features Tab
    Dynamic feature loading based on current game
]]

local FeaturesTab = {}
FeaturesTab.__index = FeaturesTab

local TweenService = game:GetService("TweenService")

local GITHUB_RAW = "https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/"

local Theme = nil
local Container = nil
local LoadedModules = {}
local FeatureElements = {}

local function fetch(path)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. path)
    end)
    if success then return result end
    return nil
end

local function loadModule(path)
    local source = fetch(path)
    if source then
        local fn = loadstring(source)
        if fn then return fn() end
    end
    return nil
end

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

local function createToggle(parent, feature, layoutOrder)
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

local function createSlider(parent, feature, layoutOrder)
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

function FeaturesTab:Create(parent, theme, gameDetector)
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
    
    if not gameDetector or not gameDetector:IsSupported() then
        local unsupportedLabel = Instance.new("TextLabel")
        unsupportedLabel.Name = "Unsupported"
        unsupportedLabel.Size = UDim2.new(1, 0, 0, 100)
        unsupportedLabel.BackgroundTransparency = 1
        unsupportedLabel.Text = "⚠️ This game is not supported.\nNo features available."
        unsupportedLabel.TextColor3 = Theme.Colors.TextMuted
        unsupportedLabel.TextSize = 14
        unsupportedLabel.Font = Theme.Fonts.Body
        unsupportedLabel.TextWrapped = true
        unsupportedLabel.LayoutOrder = 1
        unsupportedLabel.Parent = Container
        
        return Container
    end
    
    local gameName = gameDetector:GetGameName()
    local gameIcon = gameDetector:GetGameIcon()
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = gameIcon .. " " .. gameName .. " Features"
    header.TextColor3 = Theme.Colors.Text
    header.TextSize = 16
    header.Font = Theme.Fonts.Title
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.Parent = Container
    
    local featuresPath = gameDetector:GetFeaturesPath()
    if featuresPath then
        local gameFeatures = loadModule(featuresPath)
        
        if gameFeatures and gameFeatures.Features then
            for i, feature in ipairs(gameFeatures.Features) do
                if feature.Type == "slider" then
                    createSlider(Container, feature, i + 1)
                else
                    createToggle(Container, feature, i + 1)
                end
            end
        end
    end
    
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
