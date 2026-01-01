--[[
    WindHub Toggle Dropdown Control
    Toggle switch with dropdown options (e.g. ESP with team check)
]]

local ToggleDropdown = {}

local TweenService = game:GetService("TweenService")

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

function ToggleDropdown.Create(parent, feature, layoutOrder, Theme, loadModule, LoadedModules, FeatureElements)
    local featureModule = loadModule(feature.Module)
    if featureModule then
        LoadedModules[feature.Name] = featureModule
    end
    
    local container = Instance.new("Frame")
    container.Name = feature.Name
    container.Size = UDim2.new(1, 0, 0, 100)
    container.BackgroundColor3 = Theme.Colors.Card
    container.LayoutOrder = layoutOrder
    container.ClipsDescendants = true
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = container
    
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
    titleLabel.Parent = container
    
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
    descLabel.Parent = container
    
    local switchBg = Instance.new("TextButton")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 44, 0, 24)
    switchBg.Position = UDim2.new(1, -60, 0, 18)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Theme.Colors.Secondary
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = container
    
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
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "DropdownLabel"
    dropdownLabel.Size = UDim2.new(0, 80, 0, 20)
    dropdownLabel.Position = UDim2.new(0, 16, 0, 60)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = feature.DropdownLabel or "Option:"
    dropdownLabel.TextColor3 = Theme.Colors.TextMuted
    dropdownLabel.TextSize = 11
    dropdownLabel.Font = Theme.Fonts.Body
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = container
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Name = "SelectBtn"
    selectBtn.Size = UDim2.new(1, -112, 0, 28)
    selectBtn.Position = UDim2.new(0, 96, 0, 58)
    selectBtn.BackgroundColor3 = Theme.Colors.Secondary
    selectBtn.Text = feature.DropdownDefault or feature.DropdownOptions[1] or "Select..."
    selectBtn.TextColor3 = Theme.Colors.Text
    selectBtn.TextSize = 12
    selectBtn.Font = Theme.Fonts.Body
    selectBtn.AutoButtonColor = false
    selectBtn.Parent = container
    
    local selectCorner = Instance.new("UICorner")
    selectCorner.CornerRadius = UDim.new(0, 6)
    selectCorner.Parent = selectBtn
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(0, 20, 1, 0)
    arrowLabel.Position = UDim2.new(1, -24, 0, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = Theme.Colors.TextMuted
    arrowLabel.TextSize = 10
    arrowLabel.Font = Theme.Fonts.Body
    arrowLabel.Parent = selectBtn
    
    local optionsList = Instance.new("Frame")
    optionsList.Name = "OptionsList"
    optionsList.Size = UDim2.new(1, -112, 0, 0)
    optionsList.Position = UDim2.new(0, 96, 0, 90)
    optionsList.BackgroundColor3 = Theme.Colors.CardSecondary
    optionsList.ClipsDescendants = true
    optionsList.Visible = false
    optionsList.Parent = container
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = optionsList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = optionsList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.Parent = optionsList
    
    local isEnabled = false
    local isDropdownOpen = false
    
    for i, option in ipairs(feature.DropdownOptions or {}) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = "Option_" .. i
        optionBtn.Size = UDim2.new(1, 0, 0, 26)
        optionBtn.BackgroundColor3 = Theme.Colors.Secondary
        optionBtn.BackgroundTransparency = 0.5
        optionBtn.Text = option
        optionBtn.TextColor3 = Theme.Colors.Text
        optionBtn.TextSize = 11
        optionBtn.Font = Theme.Fonts.Body
        optionBtn.AutoButtonColor = false
        optionBtn.LayoutOrder = i
        optionBtn.Parent = optionsList
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optionBtn
        
        optionBtn.MouseEnter:Connect(function()
            createTween(optionBtn, {BackgroundTransparency = 0}, 0.1):Play()
        end)
        
        optionBtn.MouseLeave:Connect(function()
            createTween(optionBtn, {BackgroundTransparency = 0.5}, 0.1):Play()
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            selectBtn.Text = option
            
            if featureModule and featureModule.SetTeamCheck then
                featureModule:SetTeamCheck(option)
            end
            
            isDropdownOpen = false
            optionsList.Visible = false
            createTween(container, {Size = UDim2.new(1, 0, 0, 100)}, 0.15):Play()
        end)
    end
    
    local optionCount = #(feature.DropdownOptions or {})
    local listHeight = optionCount * 28 + 8
    
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
    
    selectBtn.MouseEnter:Connect(function()
        createTween(selectBtn, {BackgroundColor3 = Theme.Colors.SecondaryHover}, 0.15):Play()
    end)
    
    selectBtn.MouseLeave:Connect(function()
        createTween(selectBtn, {BackgroundColor3 = Theme.Colors.Secondary}, 0.15):Play()
    end)
    
    selectBtn.MouseButton1Click:Connect(function()
        isDropdownOpen = not isDropdownOpen
        
        if isDropdownOpen then
            optionsList.Size = UDim2.new(1, -112, 0, listHeight)
            createTween(container, {Size = UDim2.new(1, 0, 0, 100 + listHeight + 8)}, 0.15):Play()
            task.wait(0.05)
            optionsList.Visible = true
        else
            optionsList.Visible = false
            createTween(container, {Size = UDim2.new(1, 0, 0, 100)}, 0.15):Play()
        end
    end)
    
    FeatureElements[feature.Name] = {
        Frame = container,
        Switch = switchBg,
        Knob = switchKnob,
        Module = featureModule,
    }
    
    return container
end

return ToggleDropdown
