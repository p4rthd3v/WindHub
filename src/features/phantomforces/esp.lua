--[[
    WindHub Phantom Forces ESP Feature
    Highlights players through walls with distance
    Works with PF's team system (Phantoms vs Ghosts)
]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local TeamCheckEnabled = false
local Highlights = {}
local DistanceLabels = {}
local UpdateConnection = nil
local CharacterConnections = {}
local PlayerAddedConnection = nil
local PlayerRemovingConnection = nil

local ESP_COLOR_ENEMY = Color3.fromRGB(255, 75, 75)
local ESP_COLOR_ALLY = Color3.fromRGB(75, 175, 255)
local FILL_TRANSPARENCY = 0.7
local OUTLINE_TRANSPARENCY = 0

local function getMyTeam()
    if LocalPlayer.Team then
        return LocalPlayer.Team.Name
    end
    return nil
end

local function getPlayerTeam(player)
    if player.Team then
        return player.Team.Name
    end
    return nil
end

local function isEnemy(player)
    local myTeam = getMyTeam()
    local theirTeam = getPlayerTeam(player)
    
    if myTeam == nil or theirTeam == nil then
        return true
    end
    
    return myTeam ~= theirTeam
end

local function getCharacter(player)
    if player.Character then
        return player.Character
    end
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == player.Name then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                return obj
            end
        end
    end
    
    return nil
end

local function getRootPart(character)
    if not character then return nil end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return root end
    
    root = character:FindFirstChild("Torso")
    if root then return root end
    
    root = character:FindFirstChild("UpperTorso")
    if root then return root end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RootPart then
        return humanoid.RootPart
    end
    
    return nil
end

local function getHead(character)
    if not character then return nil end
    
    local head = character:FindFirstChild("Head")
    if head then return head end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part.Name == "Head" and part:IsA("BasePart") then
            return part
        end
    end
    
    return nil
end

local function getDistance(position)
    local myChar = getCharacter(LocalPlayer)
    if not myChar then return 0 end
    
    local myRoot = getRootPart(myChar)
    if not myRoot then return 0 end
    
    return math.floor((myRoot.Position - position).Magnitude)
end

local function createDistanceLabel(character, espColor)
    if not character then return nil end
    
    local head = getHead(character)
    if not head then return nil end
    
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
    
    local character = getCharacter(player)
    if not character then return end
    
    if TeamCheckEnabled and not isEnemy(player) then
        removeHighlight(player)
        return
    end
    
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
    end
    if DistanceLabels[player] then
        pcall(function() DistanceLabels[player]:Destroy() end)
    end
    
    local espColor = isEnemy(player) and ESP_COLOR_ENEMY or ESP_COLOR_ALLY
    
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
    
    local distanceGui = createDistanceLabel(character, espColor)
    if distanceGui then
        DistanceLabels[player] = distanceGui
    end
end

local function setupPlayerConnections(player)
    if player == LocalPlayer then return end
    
    if CharacterConnections[player] then
        pcall(function() CharacterConnections[player]:Disconnect() end)
    end
    
    CharacterConnections[player] = player.CharacterAdded:Connect(function()
        if IsEnabled then
            task.wait(1)
            createHighlight(player)
        end
    end)
    
    local character = getCharacter(player)
    if character and IsEnabled then
        task.spawn(function()
            task.wait(0.5)
            createHighlight(player)
        end)
    end
end

local function refreshAllHighlights()
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
    for player, gui in pairs(DistanceLabels) do
        if gui and gui.Parent then
            local character = getCharacter(player)
            if character then
                local root = getRootPart(character)
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

function ESP:Enable()
    if IsEnabled then return end
    IsEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayerConnections(player)
    end
    
    PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if IsEnabled then
            task.wait(1)
            setupPlayerConnections(player)
        end
    end)
    
    PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateDistances()
        end
    end)
end

function ESP:Disable()
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
        if isEnemy(player) then
            pcall(function()
                highlight.FillColor = color
                highlight.OutlineColor = color
            end)
        end
    end
end

return ESP
