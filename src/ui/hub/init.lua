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
        if ContentFrame then
            ContentFrame.Visible = false
        end
        createTween(MainFrame, {Size = UDim2.new(0, 200, 0, 50)}, 0.3):Play()
    else
        createTween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3):Play()
        task.wait(0.3)
        if ContentFrame then
            ContentFrame.Visible = true
        end
    end
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
