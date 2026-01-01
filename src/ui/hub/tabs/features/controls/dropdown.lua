--[[
    WindHub Dropdown Control
    Player selector dropdown for teleport features
]]

local Dropdown = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

function Dropdown.Create(parent, feature, layoutOrder, Theme, loadModule, LoadedModules, FeatureElements)
    local featureModule = loadModule(feature.Module)
    if featureModule then
        LoadedModules[feature.Name] = featureModule
    end
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = feature.Name
    dropdown.Size = UDim2.new(1, 0, 0, 90)
    dropdown.BackgroundColor3 = Theme.Colors.Card
    dropdown.LayoutOrder = layoutOrder
    dropdown.ClipsDescendants = true
    dropdown.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = dropdown
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = dropdown
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 0, 22)
    titleLabel.Position = UDim2.new(0, 16, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = feature.Name
    titleLabel.TextColor3 = Theme.Colors.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Theme.Fonts.Subtitle
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = dropdown
    
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
    descLabel.Parent = dropdown
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Name = "SelectBtn"
    selectBtn.Size = UDim2.new(1, -32, 0, 32)
    selectBtn.Position = UDim2.new(0, 16, 0, 50)
    selectBtn.BackgroundColor3 = Theme.Colors.Secondary
    selectBtn.Text = "Select Player..."
    selectBtn.TextColor3 = Theme.Colors.TextMuted
    selectBtn.TextSize = 12
    selectBtn.Font = Theme.Fonts.Body
    selectBtn.AutoButtonColor = false
    selectBtn.Parent = dropdown
    
    local selectCorner = Instance.new("UICorner")
    selectCorner.CornerRadius = Theme.Sizes.CornerRadius
    selectCorner.Parent = selectBtn
    
    local playerList = Instance.new("Frame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, -32, 0, 150)
    playerList.Position = UDim2.new(0, 16, 0, 88)
    playerList.BackgroundColor3 = Theme.Colors.CardSecondary
    playerList.Visible = false
    playerList.Parent = dropdown
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = Theme.Sizes.CornerRadius
    listCorner.Parent = playerList
    
    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Name = "Scroll"
    listScroll.Size = UDim2.new(1, -8, 1, -8)
    listScroll.Position = UDim2.new(0, 4, 0, 4)
    listScroll.BackgroundTransparency = 1
    listScroll.ScrollBarThickness = 3
    listScroll.ScrollBarImageColor3 = Theme.Colors.Primary
    listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroll.Parent = playerList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listScroll
    
    local isOpen = false
    
    local function refreshPlayerList()
        for _, child in ipairs(listScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local localPlayer = Players.LocalPlayer
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                local playerBtn = Instance.new("TextButton")
                playerBtn.Name = player.Name
                playerBtn.Size = UDim2.new(1, 0, 0, 28)
                playerBtn.BackgroundColor3 = Theme.Colors.Secondary
                playerBtn.BackgroundTransparency = 0.5
                playerBtn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                playerBtn.TextColor3 = Theme.Colors.Text
                playerBtn.TextSize = 11
                playerBtn.Font = Theme.Fonts.Body
                playerBtn.TextTruncate = Enum.TextTruncate.AtEnd
                playerBtn.AutoButtonColor = false
                playerBtn.Parent = listScroll
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = playerBtn
                
                playerBtn.MouseEnter:Connect(function()
                    createTween(playerBtn, {BackgroundTransparency = 0}, 0.1):Play()
                end)
                
                playerBtn.MouseLeave:Connect(function()
                    createTween(playerBtn, {BackgroundTransparency = 0.5}, 0.1):Play()
                end)
                
                playerBtn.MouseButton1Click:Connect(function()
                    if featureModule and featureModule.ToPlayer then
                        local success, msg = featureModule:ToPlayer(player.Name)
                        selectBtn.Text = success and ("Teleported to " .. player.DisplayName) or msg
                        selectBtn.TextColor3 = success and Theme.Colors.Success or Theme.Colors.Error
                        
                        task.delay(2, function()
                            selectBtn.Text = "Select Player..."
                            selectBtn.TextColor3 = Theme.Colors.TextMuted
                        end)
                    end
                    
                    isOpen = false
                    playerList.Visible = false
                    createTween(dropdown, {Size = UDim2.new(1, 0, 0, 90)}, 0.2):Play()
                end)
            end
        end
    end
    
    selectBtn.MouseEnter:Connect(function()
        createTween(selectBtn, {BackgroundColor3 = Theme.Colors.SecondaryHover}, 0.15):Play()
    end)
    
    selectBtn.MouseLeave:Connect(function()
        createTween(selectBtn, {BackgroundColor3 = Theme.Colors.Secondary}, 0.15):Play()
    end)
    
    selectBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            refreshPlayerList()
            createTween(dropdown, {Size = UDim2.new(1, 0, 0, 250)}, 0.2):Play()
            task.wait(0.1)
            playerList.Visible = true
        else
            playerList.Visible = false
            createTween(dropdown, {Size = UDim2.new(1, 0, 0, 90)}, 0.2):Play()
        end
    end)
    
    FeatureElements[feature.Name] = {
        Frame = dropdown,
        Module = featureModule,
    }
    
    return dropdown
end

return Dropdown
