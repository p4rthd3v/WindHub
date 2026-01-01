--[[
    WindHub Key UI
    Premium key verification interface
]]

local KeyUI = {}
KeyUI.__index = KeyUI

local TweenService = game:GetService("TweenService")

local GITHUB_RAW = "https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/"

local Auth = nil
local ScreenGui = nil
local IsVerified = false
local OnSuccess = nil

local Colors = {
    Background = Color3.fromRGB(12, 12, 15),
    Card = Color3.fromRGB(18, 18, 22),
    CardBorder = Color3.fromRGB(35, 35, 45),
    Primary = Color3.fromRGB(99, 102, 241),
    PrimaryHover = Color3.fromRGB(129, 132, 255),
    PrimaryGlow = Color3.fromRGB(99, 102, 241),
    Text = Color3.fromRGB(245, 245, 250),
    TextMuted = Color3.fromRGB(115, 115, 130),
    Input = Color3.fromRGB(25, 25, 32),
    InputBorder = Color3.fromRGB(45, 45, 55),
    InputFocus = Color3.fromRGB(99, 102, 241),
    Error = Color3.fromRGB(239, 68, 68),
    Success = Color3.fromRGB(34, 197, 94),
}

local function loadAuth()
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. "core/auth.lua")
    end)
    
    if success and result then
        local fn = loadstring(result)
        if fn then
            Auth = fn()
            Auth:Init()
            return true
        end
    end
    return false
end

local function createTween(instance, props, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
    return tween
end

local function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}, 0.2):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = normalColor}, 0.2):Play()
    end)
end



local function createUI()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindHubKey"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "Overlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.Parent = ScreenGui
    
    local Card = Instance.new("Frame")
    Card.Name = "Card"
    Card.Size = UDim2.new(0, 380, 0, 420)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Colors.Card
    Card.BackgroundTransparency = 1
    Card.Parent = Overlay
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 16)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Colors.CardBorder
    CardStroke.Thickness = 1
    CardStroke.Transparency = 1
    CardStroke.Parent = Card
    

    
    local Logo = Instance.new("TextLabel")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.Position = UDim2.new(0, 0, 0, 35)
    Logo.BackgroundTransparency = 1
    Logo.Text = "🌀 WINDHUB"
    Logo.TextColor3 = Colors.Text
    Logo.TextSize = 28
    Logo.Font = Enum.Font.GothamBold
    Logo.TextTransparency = 1
    Logo.Parent = Card
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 85)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Enter your key to continue"
    Subtitle.TextColor3 = Colors.TextMuted
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Card
    
    local InputContainer = Instance.new("Frame")
    InputContainer.Name = "InputContainer"
    InputContainer.Size = UDim2.new(1, -50, 0, 50)
    InputContainer.Position = UDim2.new(0, 25, 0, 140)
    InputContainer.BackgroundColor3 = Colors.Input
    InputContainer.BackgroundTransparency = 1
    InputContainer.Parent = Card
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputContainer
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Colors.InputBorder
    InputStroke.Thickness = 1
    InputStroke.Transparency = 1
    InputStroke.Parent = InputContainer
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(1, -20, 1, 0)
    KeyInput.Position = UDim2.new(0, 10, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "WIND-XXXX-XXXX-XXXX"
    KeyInput.PlaceholderColor3 = Colors.TextMuted
    KeyInput.TextColor3 = Colors.Text
    KeyInput.TextSize = 16
    KeyInput.Font = Enum.Font.GothamMedium
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.ClearTextOnFocus = false
    KeyInput.TextTransparency = 1
    KeyInput.Parent = InputContainer
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -50, 0, 40)
    StatusLabel.Position = UDim2.new(0, 25, 0, 200)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Colors.Error
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.TextTransparency = 1
    StatusLabel.Parent = Card
    
    local VerifyButton = Instance.new("TextButton")
    VerifyButton.Name = "VerifyButton"
    VerifyButton.Size = UDim2.new(1, -50, 0, 48)
    VerifyButton.Position = UDim2.new(0, 25, 0, 255)
    VerifyButton.BackgroundColor3 = Colors.Primary
    VerifyButton.BackgroundTransparency = 1
    VerifyButton.Text = "VERIFY KEY"
    VerifyButton.TextColor3 = Colors.Text
    VerifyButton.TextSize = 15
    VerifyButton.Font = Enum.Font.GothamBold
    VerifyButton.AutoButtonColor = false
    VerifyButton.TextTransparency = 1
    VerifyButton.Parent = Card
    
    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 10)
    VerifyCorner.Parent = VerifyButton
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Size = UDim2.new(1, -50, 0, 48)
    GetKeyButton.Position = UDim2.new(0, 25, 0, 315)
    GetKeyButton.BackgroundColor3 = Colors.Input
    GetKeyButton.BackgroundTransparency = 1
    GetKeyButton.Text = "🔑 GET A KEY"
    GetKeyButton.TextColor3 = Colors.TextMuted
    GetKeyButton.TextSize = 14
    GetKeyButton.Font = Enum.Font.GothamMedium
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.TextTransparency = 1
    GetKeyButton.Parent = Card
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 10)
    GetKeyCorner.Parent = GetKeyButton
    
    local GetKeyStroke = Instance.new("UIStroke")
    GetKeyStroke.Color = Colors.InputBorder
    GetKeyStroke.Thickness = 1
    GetKeyStroke.Transparency = 1
    GetKeyStroke.Parent = GetKeyButton
    
    local Footer = Instance.new("TextLabel")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -30)
    Footer.BackgroundTransparency = 1
    Footer.Text = "WindHub v1.0 • Premium Script Hub"
    Footer.TextColor3 = Colors.TextMuted
    Footer.TextSize = 11
    Footer.Font = Enum.Font.Gotham
    Footer.TextTransparency = 1
    Footer.Parent = Card
    
    task.spawn(function()
        task.wait(0.1)
        
        createTween(Card, {BackgroundTransparency = 0}, 0.4):Play()
        createTween(CardStroke, {Transparency = 0}, 0.4):Play()
        task.wait(0.15)
        
        createTween(Logo, {TextTransparency = 0}, 0.3):Play()
        task.wait(0.1)
        createTween(Subtitle, {TextTransparency = 0}, 0.3):Play()
        task.wait(0.1)
        
        createTween(InputContainer, {BackgroundTransparency = 0}, 0.3):Play()
        createTween(InputStroke, {Transparency = 0}, 0.3):Play()
        createTween(KeyInput, {TextTransparency = 0}, 0.3):Play()
        task.wait(0.1)
        
        createTween(VerifyButton, {BackgroundTransparency = 0}, 0.3):Play()
        createTween(VerifyButton, {TextTransparency = 0}, 0.3):Play()
        task.wait(0.1)
        
        createTween(GetKeyButton, {BackgroundTransparency = 0}, 0.3):Play()
        createTween(GetKeyButton, {TextTransparency = 0}, 0.3):Play()
        createTween(GetKeyStroke, {Transparency = 0}, 0.3):Play()
        task.wait(0.1)
        
        createTween(Footer, {TextTransparency = 0}, 0.3):Play()
    end)
    
    KeyInput.Focused:Connect(function()
        createTween(InputStroke, {Color = Colors.InputFocus}, 0.2):Play()
    end)
    
    KeyInput.FocusLost:Connect(function()
        createTween(InputStroke, {Color = Colors.InputBorder}, 0.2):Play()
    end)
    
    addHoverEffect(VerifyButton, Colors.Primary, Colors.PrimaryHover)
    addHoverEffect(GetKeyButton, Colors.Input, Color3.fromRGB(35, 35, 45))
    
    local function showStatus(message, isError)
        StatusLabel.TextColor3 = isError and Colors.Error or Colors.Success
        StatusLabel.Text = message
        createTween(StatusLabel, {TextTransparency = 0}, 0.2):Play()
    end
    
    local function hideStatus()
        createTween(StatusLabel, {TextTransparency = 1}, 0.2):Play()
    end
    
    local function onSuccess(isDev)
        VerifyButton.Text = "SUCCESS!"
        createTween(VerifyButton, {BackgroundColor3 = Colors.Success}, 0.2):Play()
        showStatus("Access Granted" .. (isDev and " (Developer)" or ""), false)
        
        task.wait(1.5)
        
        createTween(Card, {Position = UDim2.new(0.5, 0, 0, -500)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        
        task.wait(0.5)
        ScreenGui:Destroy()
        
        if OnSuccess then
            OnSuccess(isDev)
        end
    end
    
    local function verifyKey()
        hideStatus()
        
        local key = KeyInput.Text
        if key == "" then
            showStatus("Please enter a key", true)
            return
        end
        
        VerifyButton.Text = "VERIFYING..."
        
        task.spawn(function()
            local success, message, isDev = Auth:ValidateKey(key)
            
            if success then
                onSuccess(isDev)
            else
                VerifyButton.Text = "VERIFY KEY"
                showStatus(message, true)
                
                createTween(InputStroke, {Color = Colors.Error}, 0.2):Play()
                task.wait(1)
                createTween(InputStroke, {Color = Colors.InputBorder}, 0.2):Play()
            end
        end)
    end
    
    VerifyButton.MouseButton1Click:Connect(verifyKey)
    
    GetKeyButton.MouseButton1Click:Connect(function()
        if Auth then
            local link = Auth:GetKeyLink()
            if setclipboard then
                setclipboard(link)
                showStatus("Key link copied to clipboard!", false)
            end
        end
    end)
    
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyKey()
        end
    end)
    
    return ScreenGui
end

function KeyUI:Show(callback)
    OnSuccess = callback
    
    if not loadAuth() then
        warn("[WindHub] Failed to load authentication module")
        return false
    end
    
    createUI()
    return true
end

function KeyUI:IsVerified()
    return IsVerified
end

function KeyUI:Destroy()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
end

return KeyUI
