--[[
    WindHub Settings Tab
    Hub settings and configuration
]]

local SettingsTab = {}
SettingsTab.__index = SettingsTab

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

local function createSettingRow(parent, icon, name, description, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Theme.Colors.Card
    row.LayoutOrder = layoutOrder
    row.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.Sizes.CornerRadius
    corner.Parent = row
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = row
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Font = Theme.Fonts.Body
    iconLabel.Parent = row
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Theme.Colors.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Theme.Fonts.Subtitle
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -60, 0, 14)
    descLabel.Position = UDim2.new(0, 50, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Theme.Colors.TextMuted
    descLabel.TextSize = 10
    descLabel.Font = Theme.Fonts.Body
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = row
    
    return row
end

function SettingsTab:Create(parent, theme)
    Theme = theme
    
    Container = Instance.new("ScrollingFrame")
    Container.Name = "SettingsTab"
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
    header.Text = "⚙️ Settings"
    header.TextColor3 = Theme.Colors.Text
    header.TextSize = 16
    header.Font = Theme.Fonts.Title
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.Parent = Container
    
    createSettingRow(Container, "🎨", "Theme", "Customize the hub appearance", 2)
    createSettingRow(Container, "🔔", "Notifications", "Toggle in-game notifications", 3)
    createSettingRow(Container, "💾", "Save Config", "Save your feature settings", 4)
    
    local footer = Instance.new("TextLabel")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, 0, 0, 40)
    footer.BackgroundTransparency = 1
    footer.Text = "WindHub v1.1 • Made with ❤️"
    footer.TextColor3 = Theme.Colors.TextDark
    footer.TextSize = 11
    footer.Font = Theme.Fonts.Body
    footer.LayoutOrder = 100
    footer.Parent = Container
    
    return Container
end

function SettingsTab:Show()
    if Container then
        Container.Visible = true
    end
end

function SettingsTab:Hide()
    if Container then
        Container.Visible = false
    end
end

function SettingsTab:GetContainer()
    return Container
end

return SettingsTab
