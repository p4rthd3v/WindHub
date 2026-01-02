--[[
    WindHub Phantom Forces ESP Feature
    Uses Scanner module for robust character detection
    Debug mode enabled for troubleshooting
]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GITHUB_RAW = "https://raw.githubusercontent.com/p4rthd3v/WindHub/main/src/"

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

local Scanner = nil
local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local TeamCheckEnabled = false
local Highlights = {}
local DistanceLabels = {}
local UpdateConnection = nil
local CharacterConnections = {}
local PlayerAddedConnection = nil
local PlayerRemovingConnection = nil
local ScanConnection = nil

local DEBUG = true

local ESP_COLOR_ENEMY = Color3.fromRGB(255, 75, 75)
local ESP_COLOR_ALLY = Color3.fromRGB(75, 175, 255)
local FILL_TRANSPARENCY = 0.7
local OUTLINE_TRANSPARENCY = 0

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF ESP]", ...)
    end
end

local function getDistance(position)
    if not Scanner then return 0 end
    
    local myChar = Scanner.GetCharacter(LocalPlayer)
    if not myChar then return 0 end
    
    local myRoot = Scanner.GetRootPart(myChar)
    if not myRoot then return 0 end
    
    return math.floor((myRoot.Position - position).Magnitude)
end

local function createDistanceLabel(character, espColor)
    if not Scanner then return nil end
    if not character then return nil end
    
    local head = Scanner.GetHead(character)
    if not head then
        debugPrint("No head found for distance label")
        return nil
    end
    
    local existing = head:FindFirstChild("WindHubDistance")
    if existing then existing:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "WindHubDistance"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Name = "Distance"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "0m"
    label.TextColor3 = espColor
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    return billboard
end

local function removeHighlight(player)
    if Highlights[player] then
        pcall(function()
            Highlights[player]:Destroy()
        end)
        Highlights[player] = nil
    end
    if DistanceLabels[player] then
        pcall(function()
            DistanceLabels[player]:Destroy()
        end)
        DistanceLabels[player] = nil
    end
    if CharacterConnections[player] then
        pcall(function()
            CharacterConnections[player]:Disconnect()
        end)
        CharacterConnections[player] = nil
    end
end

local function createHighlight(player)
    if player == LocalPlayer then return end
    if not Scanner then 
        debugPrint("Scanner not loaded!")
        return 
    end
    
    local character = Scanner.GetCharacter(player)
    if not character then
        debugPrint("No character for:", player.Name)
        return
    end
    
    debugPrint("Creating highlight for:", player.Name)
    
    local isEnemy = Scanner.IsEnemy(player)
    
    if TeamCheckEnabled and not isEnemy then
        debugPrint("Skipping ally:", player.Name)
        removeHighlight(player)
        return
    end
    
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
    end
    if DistanceLabels[player] then
        pcall(function() DistanceLabels[player]:Destroy() end)
    end
    
    local espColor = isEnemy and ESP_COLOR_ENEMY or ESP_COLOR_ALLY
    
    local existing = character:FindFirstChild("WindHubESP")
    if existing then existing:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WindHubESP"
    highlight.Adornee = character
    highlight.FillColor = espColor
    highlight.OutlineColor = espColor
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    Highlights[player] = highlight
    debugPrint("Highlight created for:", player.Name)
    
    local distanceGui = createDistanceLabel(character, espColor)
    if distanceGui then
        DistanceLabels[player] = distanceGui
        debugPrint("Distance label created for:", player.Name)
    end
end

local function setupPlayerConnections(player)
    if player == LocalPlayer then return end
    
    if CharacterConnections[player] then
        pcall(function() CharacterConnections[player]:Disconnect() end)
    end
    
    CharacterConnections[player] = player.CharacterAdded:Connect(function()
        debugPrint("CharacterAdded for:", player.Name)
        if IsEnabled then
            task.wait(1.5)
            createHighlight(player)
        end
    end)
    
    if IsEnabled then
        task.spawn(function()
            task.wait(0.5)
            createHighlight(player)
        end)
    end
end

local function refreshAllHighlights()
    debugPrint("Refreshing all highlights...")
    
    local playersToRemove = {}
    for player, _ in pairs(Highlights) do
        table.insert(playersToRemove, player)
    end
    
    for _, player in ipairs(playersToRemove) do
        removeHighlight(player)
    end
    
    if IsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                task.spawn(function()
                    createHighlight(player)
                end)
            end
        end
    end
end

local function updateDistances()
    if not Scanner then return end
    
    for player, gui in pairs(DistanceLabels) do
        if gui and gui.Parent then
            local character = Scanner.GetCharacter(player)
            if character then
                local root = Scanner.GetRootPart(character)
                if root then
                    local distance = getDistance(root.Position)
                    local label = gui:FindFirstChild("Distance")
                    if label then
                        label.Text = distance .. "m"
                    end
                end
            end
        end
    end
end

local function periodicScan()
    if not IsEnabled then return end
    if not Scanner then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local hasHighlight = Highlights[player] ~= nil
            local character = Scanner.GetCharacter(player)
            
            if character and not hasHighlight then
                debugPrint("Periodic scan found new character:", player.Name)
                createHighlight(player)
            elseif not character and hasHighlight then
                debugPrint("Periodic scan removing dead/missing:", player.Name)
                removeHighlight(player)
            end
        end
    end
end

function ESP:Enable()
    if IsEnabled then return end
    debugPrint("Enabling ESP...")
    
    IsEnabled = true
    
    Scanner = loadModule("features/phantomforces/scanner.lua")
    if Scanner then
        debugPrint("Scanner loaded, running init...")
        Scanner.Init()
    else
        debugPrint("ERROR: Failed to load scanner!")
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayerConnections(player)
    end
    
    PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        debugPrint("PlayerAdded:", player.Name)
        if IsEnabled then
            task.wait(2)
            setupPlayerConnections(player)
        end
    end)
    
    PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        debugPrint("PlayerRemoving:", player.Name)
        removeHighlight(player)
    end)
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateDistances()
        end
    end)
    
    task.spawn(function()
        while IsEnabled do
            periodicScan()
            task.wait(2)
        end
    end)
    
    debugPrint("ESP Enabled!")
end

function ESP:Disable()
    debugPrint("Disabling ESP...")
    IsEnabled = false
    
    local playersToRemove = {}
    for player, _ in pairs(Highlights) do
        table.insert(playersToRemove, player)
    end
    
    for _, player in ipairs(playersToRemove) do
        removeHighlight(player)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end
    
    if PlayerAddedConnection then
        PlayerAddedConnection:Disconnect()
        PlayerAddedConnection = nil
    end
    
    if PlayerRemovingConnection then
        PlayerRemovingConnection:Disconnect()
        PlayerRemovingConnection = nil
    end
    
    debugPrint("ESP Disabled!")
end

function ESP:Toggle(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function ESP:IsEnabled()
    return IsEnabled
end

function ESP:SetTeamCheck(option)
    debugPrint("SetTeamCheck:", option)
    if option == "Enemies Only" then
        TeamCheckEnabled = true
    else
        TeamCheckEnabled = false
    end
    
    if IsEnabled then
        refreshAllHighlights()
    end
end

function ESP:SetColor(color)
    ESP_COLOR_ENEMY = color
    for player, highlight in pairs(Highlights) do
        if Scanner and Scanner.IsEnemy(player) then
            pcall(function()
                highlight.FillColor = color
                highlight.OutlineColor = color
            end)
        end
    end
end

function ESP:DebugPlayer(playerName)
    if not Scanner then
        debugPrint("Scanner not loaded")
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == playerName or playerName == nil then
            Scanner.DebugPlayer(player)
        end
    end
end

return ESP
