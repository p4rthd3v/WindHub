--[[
    WindHub Theme
    Shared colors and styles for the UI
]]

local Theme = {}

Theme.Colors = {
    Background = Color3.fromRGB(12, 12, 15),
    Card = Color3.fromRGB(18, 18, 22),
    CardSecondary = Color3.fromRGB(22, 22, 28),
    CardBorder = Color3.fromRGB(35, 35, 45),
    
    Primary = Color3.fromRGB(99, 102, 241),
    PrimaryHover = Color3.fromRGB(129, 132, 255),
    PrimaryDark = Color3.fromRGB(79, 82, 201),
    
    Secondary = Color3.fromRGB(45, 45, 55),
    SecondaryHover = Color3.fromRGB(55, 55, 68),
    
    Text = Color3.fromRGB(245, 245, 250),
    TextMuted = Color3.fromRGB(115, 115, 130),
    TextDark = Color3.fromRGB(85, 85, 100),
    
    Success = Color3.fromRGB(34, 197, 94),
    Error = Color3.fromRGB(239, 68, 68),
    Warning = Color3.fromRGB(234, 179, 8),
    
    Accent = Color3.fromRGB(56, 189, 248),
}

Theme.Fonts = {
    Title = Enum.Font.GothamBold,
    Subtitle = Enum.Font.GothamMedium,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code,
}

Theme.Sizes = {
    CornerRadius = UDim.new(0, 8),
    CornerRadiusLarge = UDim.new(0, 12),
    Padding = 12,
    PaddingLarge = 20,
}

return Theme
