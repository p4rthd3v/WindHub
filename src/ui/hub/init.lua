--[[
    WindHub Main Hub
    Main hub interface that ties everything together
]]

local Hub = {}
Hub.__index = Hub

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local GITHUB_RAW = "https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/"

local Theme = nil
local Toast = nil
local Sidebar = nil
local Topbar = nil
local HomeTab = nil
local FeaturesTab = nil
local SettingsTab = nil

local ScreenGui = nil
local MainFrame = nil
local ContentFrame = nil
local MiniBar = nil
local IsMinimized = false

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

local function createTween(instance, props, duration, style, direction)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
end

local function switchTab(tabName)
    if IsMinimized then return end
    
    if HomeTab then
        if tabName == "home" then HomeTab:Show() else HomeTab:Hide() end
    end
    if FeaturesTab then
        if tabName == "features" then FeaturesTab:Show() else FeaturesTab:Hide() end
    end
    if SettingsTab then
        if tabName == "settings" then SettingsTab:Show() else SettingsTab:Hide() end
    end
    
    if Topbar then
        local titles = {
            home = "Home",
            features = "Features",
            settings = "Settings",
        }
        Topbar:SetTitle(titles[tabName] or "Home")
    end
end

local function closeHub()
    if MainFrame then
        createTween(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        
        task.wait(0.3)
        if ScreenGui then
            ScreenGui:Destroy()
            ScreenGui = nil
        end
    end
end

local function minimizeHub()
    if not MainFrame then return end
    
    IsMinimized = not IsMinimized
    
    if IsMinimized then
        createTween(ContentFrame, {BackgroundTransparency = 1}, 0.15):Play()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                createTween(child, {BackgroundTransparency = 1}, 0.15):Play()
            end
        end
        task.wait(0.1)
        ContentFrame.Visible = false
        MiniBar.Visible = true
        createTween(MainFrame, {Size = UDim2.new(0, 220, 0, 45)}, 0.25, Enum.EasingStyle.Quint):Play()
    else
        createTween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.35, Enum.EasingStyle.Quint):Play()
        task.wait(0.25)
        MiniBar.Visible = false
        ContentFrame.Visible = true
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                createTween(child, {BackgroundTransparency = 0}, 0.2):Play()
            end
        end
    end
end

local function createMiniBar(parent)
    local UserInputService = game:GetService("UserInputService")
    local dragConnection = nil
    local dragStart = nil
    local startPos = nil
    
    MiniBar = Instance.new("Frame")
    MiniBar.Name = "MiniBar"
    MiniBar.Size = UDim2.new(1, 0, 1, 0)
    MiniBar.BackgroundTransparency = 1
    MiniBar.Visible = false
    MiniBar.Parent = parent
    
    local dragArea = Instance.new("TextButton")
    dragArea.Name = "DragArea"
    dragArea.Size = UDim2.new(1, -85, 1, 0)
    dragArea.Position = UDim2.new(0, 0, 0, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = ""
    dragArea.AutoButtonColor = false
    dragArea.Parent = MiniBar
    
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.Position = UDim2.new(0, 12, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "🌀 WINDHUB"
    logo.TextColor3 = Theme.Colors.Text
    logo.TextSize = 14
    logo.Font = Theme.Fonts.Title
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = dragArea
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "Buttons"
    buttonContainer.Size = UDim2.new(0, 70, 0, 28)
    buttonContainer.Position = UDim2.new(1, -80, 0.5, 0)
    buttonContainer.AnchorPoint = Vector2.new(0, 0.5)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = MiniBar
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Name = "Expand"
    expandBtn.Size = UDim2.new(0, 28, 0, 28)
    expandBtn.Position = UDim2.new(0, 0, 0, 0)
    expandBtn.BackgroundColor3 = Theme.Colors.Primary
    expandBtn.Text = "+"
    expandBtn.TextColor3 = Theme.Colors.Text
    expandBtn.TextSize = 18
    expandBtn.Font = Theme.Fonts.Title
    expandBtn.AutoButtonColor = false
    expandBtn.Parent = buttonContainer
    
    local expandCorner = Instance.new("UICorner")
    expandCorner.CornerRadius = Theme.Sizes.CornerRadius
    expandCorner.Parent = expandBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(0, 35, 0, 0)
    closeBtn.BackgroundColor3 = Theme.Colors.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Theme.Colors.Text
    closeBtn.TextSize = 12
    closeBtn.Font = Theme.Fonts.Title
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = buttonContainer
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = Theme.Sizes.CornerRadius
    closeCorner.Parent = closeBtn
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = MainFrame.Position
            
            dragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = moveInput.Position - dragStart
                    MainFrame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
        end
    end)
    
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
        end
    end)
    
    expandBtn.MouseEnter:Connect(function()
        createTween(expandBtn, {BackgroundColor3 = Theme.Colors.PrimaryHover}, 0.15):Play()
    end)
    expandBtn.MouseLeave:Connect(function()
        createTween(expandBtn, {BackgroundColor3 = Theme.Colors.Primary}, 0.15):Play()
    end)
    expandBtn.MouseButton1Click:Connect(minimizeHub)
    
    closeBtn.MouseEnter:Connect(function()
        createTween(closeBtn, {BackgroundTransparency = 0}, 0.15):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        createTween(closeBtn, {BackgroundTransparency = 0.5}, 0.15):Play()
    end)
    closeBtn.MouseButton1Click:Connect(closeHub)
    
    return MiniBar
end

function Hub:Create()
    Theme = loadModule("ui/components/theme.lua")
    Toast = loadModule("ui/components/toast.lua")
    Sidebar = loadModule("ui/hub/sidebar.lua")
    Topbar = loadModule("ui/hub/topbar.lua")
    HomeTab = loadModule("ui/hub/tabs/home.lua")
    FeaturesTab = loadModule("ui/hub/tabs/features.lua")
    SettingsTab = loadModule("ui/hub/tabs/settings.lua")
    
    if not Theme then
        warn("[WindHub] Failed to load theme")
        return false
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Colors.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = Theme.Sizes.CornerRadiusLarge
    mainCorner.Parent = MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Colors.CardBorder
    mainStroke.Thickness = 1
    mainStroke.Parent = MainFrame
    
    ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    createMiniBar(MainFrame)
    
    createTween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.4, Enum.EasingStyle.Back):Play()
    
    task.wait(0.2)
    
    if Sidebar then
        Sidebar:Create(ContentFrame, Theme, function(tabName)
            switchTab(tabName)
        end)
    end
    
    if Topbar then
        Topbar:Create(ContentFrame, MainFrame, Theme, closeHub, minimizeHub)
    end
    
    if HomeTab then
        HomeTab:Create(ContentFrame, Theme)
    end
    
    if FeaturesTab then
        FeaturesTab:Create(ContentFrame, Theme)
    end
    
    if SettingsTab then
        SettingsTab:Create(ContentFrame, Theme)
    end
    
    switchTab("home")
    
    if Toast and Theme then
        Toast:Init(ScreenGui, Theme)
        
        task.wait(0.5)
        local player = Players.LocalPlayer
        Toast:Success("Welcome back, " .. player.DisplayName .. "!", 4)
    end
    
    return true
end

function Hub:ShowToast(message, toastType, duration)
    if Toast then
        Toast:Show(message, toastType, duration)
    end
end

function Hub:Destroy()
    closeHub()
end

function Hub:GetScreenGui()
    return ScreenGui
end

return Hub
