--[[
    WindHub Toast Notifications
    Elegant notification system
]]

local Toast = {}
Toast.__index = Toast

local TweenService = game:GetService("TweenService")

local Theme = nil
local Container = nil
local ActiveToasts = {}

local function createTween(instance, props, duration, style, direction)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
end

function Toast:Init(screenGui, theme)
    Theme = theme
    
    Container = Instance.new("Frame")
    Container.Name = "ToastContainer"
    Container.Size = UDim2.new(0, 300, 1, 0)
    Container.Position = UDim2.new(1, -320, 0, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = screenGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = Container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = Container
    
    return Container
end

function Toast:Show(message, toastType, duration)
    if not Container or not Theme then return end
    
    toastType = toastType or "info"
    duration = duration or 3
    
    local colors = {
        success = Theme.Colors.Success,
        error = Theme.Colors.Error,
        warning = Theme.Colors.Warning,
        info = Theme.Colors.Primary,
    }
    
    local icons = {
        success = "✓",
        error = "✕",
        warning = "⚠",
        info = "ℹ",
    }
    
    local toastColor = colors[toastType] or Theme.Colors.Primary
    local toastIcon = icons[toastType] or "ℹ"
    
    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.Size = UDim2.new(1, 0, 0, 50)
    toast.Position = UDim2.new(1, 50, 0, 0)
    toast.BackgroundColor3 = Theme.Colors.Card
    toast.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.CardBorder
    stroke.Thickness = 1
    stroke.Parent = toast
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, -10)
    accent.Position = UDim2.new(0, 5, 0, 5)
    accent.BackgroundColor3 = toastColor
    accent.Parent = toast
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accent
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 15, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = toastIcon
    icon.TextColor3 = toastColor
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Parent = toast
    
    local label = Instance.new("TextLabel")
    label.Name = "Message"
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 45, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Theme.Colors.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = toast
    
    table.insert(ActiveToasts, toast)
    
    createTween(toast, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back):Play()
    
    task.delay(duration, function()
        createTween(toast, {Position = UDim2.new(1, 50, 0, 0)}, 0.3):Play()
        task.wait(0.3)
        
        for i, t in ipairs(ActiveToasts) do
            if t == toast then
                table.remove(ActiveToasts, i)
                break
            end
        end
        
        toast:Destroy()
    end)
    
    return toast
end

function Toast:Success(message, duration)
    return self:Show(message, "success", duration)
end

function Toast:Error(message, duration)
    return self:Show(message, "error", duration)
end

function Toast:Warning(message, duration)
    return self:Show(message, "warning", duration)
end

function Toast:Info(message, duration)
    return self:Show(message, "info", duration)
end

function Toast:GetContainer()
    return Container
end

return Toast
