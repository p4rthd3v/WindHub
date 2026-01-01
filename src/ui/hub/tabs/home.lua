--[[
    WindHub Home Tab
    Welcome message and update log
]]

local HomeTab = {}
HomeTab.__index = HomeTab

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Theme = nil
local Container = nil

local UPDATES = {
    {
        version = "v1.0.0",
        date = "Jan 1, 2026",
        changes = {
            "🎉 Initial release of WindHub",
            "🔐 Secure key system implemented",
            "🎨 Premium UI design",
            "📦 Modular script loading",
        }
    },
}

function HomeTab:Create(parent, theme)
    Theme = theme
    
    Container = Instance.new("ScrollingFrame")
    Container.Name = "HomeTab"
    Container.Size = UDim2.new(1, -180, 1, -45)
    Container.Position = UDim2.new(0, 180, 0, 45)
    Container.BackgroundColor3 = Theme.Colors.Background
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Theme.Colors.Primary
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.Parent = parent
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = Container
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 16)
    layout.Parent = Container
    
    local player = Players.LocalPlayer
    
    local welcomeCard = Instance.new("Frame")
    welcomeCard.Name = "WelcomeCard"
    welcomeCard.Size = UDim2.new(1, 0, 0, 100)
    welcomeCard.BackgroundColor3 = Theme.Colors.Primary
    welcomeCard.LayoutOrder = 1
    welcomeCard.Parent = Container
    
    local welcomeCorner = Instance.new("UICorner")
    welcomeCorner.CornerRadius = Theme.Sizes.CornerRadiusLarge
    welcomeCorner.Parent = welcomeCard
    
    local welcomeTitle = Instance.new("TextLabel")
    welcomeTitle.Name = "Title"
    welcomeTitle.Size = UDim2.new(1, -30, 0, 30)
    welcomeTitle.Position = UDim2.new(0, 20, 0, 20)
    welcomeTitle.BackgroundTransparency = 1
    welcomeTitle.Text = "Welcome back, " .. player.DisplayName .. "! 👋"
    welcomeTitle.TextColor3 = Theme.Colors.Text
    welcomeTitle.TextSize = 20
    welcomeTitle.Font = Theme.Fonts.Title
    welcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
    welcomeTitle.Parent = welcomeCard
    
    local welcomeSubtitle = Instance.new("TextLabel")
    welcomeSubtitle.Name = "Subtitle"
    welcomeSubtitle.Size = UDim2.new(1, -30, 0, 20)
    welcomeSubtitle.Position = UDim2.new(0, 20, 0, 55)
    welcomeSubtitle.BackgroundTransparency = 1
    welcomeSubtitle.Text = "WindHub is ready to enhance your gameplay."
    welcomeSubtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
    welcomeSubtitle.TextSize = 14
    welcomeSubtitle.Font = Theme.Fonts.Body
    welcomeSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    welcomeSubtitle.Parent = welcomeCard
    
    local updateHeader = Instance.new("TextLabel")
    updateHeader.Name = "UpdateHeader"
    updateHeader.Size = UDim2.new(1, 0, 0, 25)
    updateHeader.BackgroundTransparency = 1
    updateHeader.Text = "📋 Update Log"
    updateHeader.TextColor3 = Theme.Colors.Text
    updateHeader.TextSize = 16
    updateHeader.Font = Theme.Fonts.Title
    updateHeader.TextXAlignment = Enum.TextXAlignment.Left
    updateHeader.LayoutOrder = 2
    updateHeader.Parent = Container
    
    for i, update in ipairs(UPDATES) do
        local updateCard = Instance.new("Frame")
        updateCard.Name = "Update_" .. i
        updateCard.Size = UDim2.new(1, 0, 0, 0)
        updateCard.AutomaticSize = Enum.AutomaticSize.Y
        updateCard.BackgroundColor3 = Theme.Colors.Card
        updateCard.LayoutOrder = 2 + i
        updateCard.Parent = Container
        
        local updateCorner = Instance.new("UICorner")
        updateCorner.CornerRadius = Theme.Sizes.CornerRadius
        updateCorner.Parent = updateCard
        
        local updateStroke = Instance.new("UIStroke")
        updateStroke.Color = Theme.Colors.CardBorder
        updateStroke.Thickness = 1
        updateStroke.Parent = updateCard
        
        local updatePadding = Instance.new("UIPadding")
        updatePadding.PaddingLeft = UDim.new(0, 16)
        updatePadding.PaddingRight = UDim.new(0, 16)
        updatePadding.PaddingTop = UDim.new(0, 16)
        updatePadding.PaddingBottom = UDim.new(0, 16)
        updatePadding.Parent = updateCard
        
        local updateLayout = Instance.new("UIListLayout")
        updateLayout.SortOrder = Enum.SortOrder.LayoutOrder
        updateLayout.Padding = UDim.new(0, 8)
        updateLayout.Parent = updateCard
        
        local versionRow = Instance.new("Frame")
        versionRow.Name = "VersionRow"
        versionRow.Size = UDim2.new(1, 0, 0, 22)
        versionRow.BackgroundTransparency = 1
        versionRow.LayoutOrder = 1
        versionRow.Parent = updateCard
        
        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(0, 60, 1, 0)
        versionLabel.BackgroundColor3 = Theme.Colors.Primary
        versionLabel.Text = update.version
        versionLabel.TextColor3 = Theme.Colors.Text
        versionLabel.TextSize = 11
        versionLabel.Font = Theme.Fonts.Title
        versionLabel.Parent = versionRow
        
        local versionCorner = Instance.new("UICorner")
        versionCorner.CornerRadius = UDim.new(0, 4)
        versionCorner.Parent = versionLabel
        
        local dateLabel = Instance.new("TextLabel")
        dateLabel.Size = UDim2.new(1, -70, 1, 0)
        dateLabel.Position = UDim2.new(0, 70, 0, 0)
        dateLabel.BackgroundTransparency = 1
        dateLabel.Text = update.date
        dateLabel.TextColor3 = Theme.Colors.TextMuted
        dateLabel.TextSize = 12
        dateLabel.Font = Theme.Fonts.Body
        dateLabel.TextXAlignment = Enum.TextXAlignment.Left
        dateLabel.Parent = versionRow
        
        for j, change in ipairs(update.changes) do
            local changeLabel = Instance.new("TextLabel")
            changeLabel.Name = "Change_" .. j
            changeLabel.Size = UDim2.new(1, 0, 0, 18)
            changeLabel.BackgroundTransparency = 1
            changeLabel.Text = change
            changeLabel.TextColor3 = Theme.Colors.TextMuted
            changeLabel.TextSize = 12
            changeLabel.Font = Theme.Fonts.Body
            changeLabel.TextXAlignment = Enum.TextXAlignment.Left
            changeLabel.LayoutOrder = 1 + j
            changeLabel.Parent = updateCard
        end
    end
    
    return Container
end

function HomeTab:Show()
    if Container then
        Container.Visible = true
    end
end

function HomeTab:Hide()
    if Container then
        Container.Visible = false
    end
end

function HomeTab:GetContainer()
    return Container
end

return HomeTab
