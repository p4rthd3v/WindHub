--[[
    WindHub Sidebar
    Left sidebar with avatar, username, and tab navigation
]]

local Sidebar = {}
Sidebar.__index = Sidebar

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Theme = nil
local Container = nil
local CurrentTab = "home"
local TabButtons = {}
local OnTabChanged = nil

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

local function createTabButton(parent, icon, name, yPos)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 40)
    button.Position = UDim2.new(0, 8, 0, yPos)
    button.BackgroundColor3 = Theme.Colors.Secondary
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = button
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Theme.Colors.TextMuted
    iconLabel.TextSize = 16
    iconLabel.Font = Theme.Fonts.Body
    iconLabel.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Colors.TextMuted
    label.TextSize = 13
    label.Font = Theme.Fonts.Subtitle
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    button.MouseEnter:Connect(function()
        if CurrentTab ~= name:lower() then
            createTween(button, {BackgroundTransparency = 0.8}, 0.15):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if CurrentTab ~= name:lower() then
            createTween(button, {BackgroundTransparency = 1}, 0.15):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        Sidebar:SetActiveTab(name:lower())
        if OnTabChanged then
            OnTabChanged(name:lower())
        end
    end)
    
    TabButtons[name:lower()] = {
        Button = button,
        Icon = iconLabel,
        Label = label,
    }
    
    return button
end

function Sidebar:Create(parent, theme, tabCallback)
    Theme = theme
    OnTabChanged = tabCallback
    
    Container = Instance.new("Frame")
    Container.Name = "Sidebar"
    Container.Size = UDim2.new(0, 180, 1, 0)
    Container.Position = UDim2.new(0, 0, 0, 0)
    Container.BackgroundColor3 = Theme.Colors.Card
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.Position = UDim2.new(1, 0, 0, 0)
    divider.BackgroundColor3 = Theme.Colors.CardBorder
    divider.BorderSizePixel = 0
    divider.Parent = Container
    
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, 0, 0, 50)
    logo.Position = UDim2.new(0, 0, 0, 12)
    logo.BackgroundTransparency = 1
    logo.Text = "🌀 WINDHUB"
    logo.TextColor3 = Theme.Colors.Text
    logo.TextSize = 18
    logo.Font = Theme.Fonts.Title
    logo.Parent = Container
    
    local tabSection = Instance.new("TextLabel")
    tabSection.Name = "TabSection"
    tabSection.Size = UDim2.new(1, -16, 0, 20)
    tabSection.Position = UDim2.new(0, 8, 0, 70)
    tabSection.BackgroundTransparency = 1
    tabSection.Text = "NAVIGATION"
    tabSection.TextColor3 = Theme.Colors.TextDark
    tabSection.TextSize = 10
    tabSection.Font = Theme.Fonts.Title
    tabSection.TextXAlignment = Enum.TextXAlignment.Left
    tabSection.Parent = Container
    
    createTabButton(Container, "🏠", "Home", 95)
    createTabButton(Container, "⚡", "Features", 140)
    createTabButton(Container, "⚙️", "Settings", 185)
    
    local player = Players.LocalPlayer
    
    local userSection = Instance.new("Frame")
    userSection.Name = "UserSection"
    userSection.Size = UDim2.new(1, -16, 0, 60)
    userSection.Position = UDim2.new(0, 8, 1, -70)
    userSection.BackgroundColor3 = Theme.Colors.CardSecondary
    userSection.Parent = Container
    
    local userCorner = Instance.new("UICorner")
    userCorner.CornerRadius = Theme.Sizes.CornerRadius
    userCorner.Parent = userSection
    
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 10, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.BackgroundColor3 = Theme.Colors.Secondary
    avatar.Image = ""
    avatar.Parent = userSection
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    task.spawn(function()
        local userId = player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        avatar.Image = content
    end)
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, -65, 0, 18)
    username.Position = UDim2.new(0, 58, 0, 14)
    username.BackgroundTransparency = 1
    username.Text = player.Name
    username.TextColor3 = Theme.Colors.Text
    username.TextSize = 12
    username.Font = Theme.Fonts.Subtitle
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.TextTruncate = Enum.TextTruncate.AtEnd
    username.Parent = userSection
    
    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.Size = UDim2.new(1, -65, 0, 14)
    displayName.Position = UDim2.new(0, 58, 0, 32)
    displayName.BackgroundTransparency = 1
    displayName.Text = "@" .. player.DisplayName
    displayName.TextColor3 = Theme.Colors.TextMuted
    displayName.TextSize = 10
    displayName.Font = Theme.Fonts.Body
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.Parent = userSection
    
    self:SetActiveTab("home")
    
    return Container
end

function Sidebar:SetActiveTab(tabName)
    CurrentTab = tabName
    
    for name, tab in pairs(TabButtons) do
        if name == tabName then
            createTween(tab.Button, {BackgroundTransparency = 0}, 0.2):Play()
            tab.Button.BackgroundColor3 = Theme.Colors.Primary
            tab.Icon.TextColor3 = Theme.Colors.Text
            tab.Label.TextColor3 = Theme.Colors.Text
        else
            createTween(tab.Button, {BackgroundTransparency = 1}, 0.2):Play()
            tab.Icon.TextColor3 = Theme.Colors.TextMuted
            tab.Label.TextColor3 = Theme.Colors.TextMuted
        end
    end
end

function Sidebar:GetContainer()
    return Container
end

return Sidebar
