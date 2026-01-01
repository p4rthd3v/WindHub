--[[
    WindHub Topbar
    Top bar with title, minimize and close buttons
]]

local Topbar = {}
Topbar.__index = Topbar

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = nil
local Container = nil
local OnClose = nil
local OnMinimize = nil

local DragConnection = nil
local DragStart = nil
local StartPos = nil

local function createTween(instance, props, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

function Topbar:Create(parent, mainFrame, theme, closeCallback, minimizeCallback)
    Theme = theme
    OnClose = closeCallback
    OnMinimize = minimizeCallback
    
    Container = Instance.new("Frame")
    Container.Name = "Topbar"
    Container.Size = UDim2.new(1, -180, 0, 45)
    Container.Position = UDim2.new(0, 180, 0, 0)
    Container.BackgroundColor3 = Theme.Colors.Card
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, 0)
    divider.BackgroundColor3 = Theme.Colors.CardBorder
    divider.BorderSizePixel = 0
    divider.Parent = Container
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Home"
    title.TextColor3 = Theme.Colors.Text
    title.TextSize = 16
    title.Font = Theme.Fonts.Subtitle
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = Container
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "Buttons"
    buttonContainer.Size = UDim2.new(0, 80, 0, 30)
    buttonContainer.Position = UDim2.new(1, -90, 0.5, 0)
    buttonContainer.AnchorPoint = Vector2.new(0, 0.5)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = Container
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    minimizeBtn.BackgroundColor3 = Theme.Colors.Secondary
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Theme.Colors.TextMuted
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Theme.Fonts.Title
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = buttonContainer
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = Theme.Sizes.CornerRadius
    minCorner.Parent = minimizeBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 40, 0, 0)
    closeBtn.BackgroundColor3 = Theme.Colors.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Colors.Text
    closeBtn.TextSize = 12
    closeBtn.Font = Theme.Fonts.Title
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = buttonContainer
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = Theme.Sizes.CornerRadius
    closeCorner.Parent = closeBtn
    
    minimizeBtn.MouseEnter:Connect(function()
        createTween(minimizeBtn, {BackgroundColor3 = Theme.Colors.SecondaryHover}, 0.15):Play()
    end)
    minimizeBtn.MouseLeave:Connect(function()
        createTween(minimizeBtn, {BackgroundColor3 = Theme.Colors.Secondary}, 0.15):Play()
    end)
    minimizeBtn.MouseButton1Click:Connect(function()
        if OnMinimize then OnMinimize() end
    end)
    
    closeBtn.MouseEnter:Connect(function()
        createTween(closeBtn, {BackgroundTransparency = 0}, 0.15):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        createTween(closeBtn, {BackgroundTransparency = 0.5}, 0.15):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        if OnClose then OnClose() end
    end)
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            DragStart = input.Position
            StartPos = mainFrame.Position
            
            DragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = moveInput.Position - DragStart
                    mainFrame.Position = UDim2.new(
                        StartPos.X.Scale, StartPos.X.Offset + delta.X,
                        StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
                    )
                end
            end)
        end
    end)
    
    Container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if DragConnection then
                DragConnection:Disconnect()
                DragConnection = nil
            end
        end
    end)
    
    return Container
end

function Topbar:SetTitle(text)
    if Container then
        local title = Container:FindFirstChild("Title")
        if title then
            title.Text = text
        end
    end
end

function Topbar:GetContainer()
    return Container
end

return Topbar
