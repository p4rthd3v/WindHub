--[[
    WindHub ESP Feature
    Highlights players through walls with outlines and distance
]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local Highlights = {}
local DistanceLabels = {}
local UpdateConnection = nil
local CharacterConnections = {}

local ESP_COLOR = Color3.fromRGB(99, 102, 241)
local FILL_TRANSPARENCY = 0.8
local OUTLINE_TRANSPARENCY = 0

local function getDistance(position)
    if not LocalPlayer.Character then return 0 end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return 0 end
    return math.floor((myRoot.Position - position).Magnitude)
end

local function createDistanceLabel(player)
    local character = player.Character
    if not character then return nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
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
    label.TextColor3 = ESP_COLOR
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    return billboard
end

local function createHighlight(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    if Highlights[player] then
        Highlights[player]:Destroy()
    end
    if DistanceLabels[player] then
        DistanceLabels[player]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WindHubESP"
    highlight.Adornee = character
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = ESP_COLOR
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    Highlights[player] = highlight
    
    local distanceGui = createDistanceLabel(player)
    if distanceGui then
        DistanceLabels[player] = distanceGui
    end
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
    if DistanceLabels[player] then
        DistanceLabels[player]:Destroy()
        DistanceLabels[player] = nil
    end
    if CharacterConnections[player] then
        CharacterConnections[player]:Disconnect()
        CharacterConnections[player] = nil
    end
end

local function setupPlayerConnections(player)
    if player == LocalPlayer then return end
    
    if CharacterConnections[player] then
        CharacterConnections[player]:Disconnect()
    end
    
    CharacterConnections[player] = player.CharacterAdded:Connect(function(character)
        if IsEnabled then
            task.wait(0.5)
            createHighlight(player)
        end
    end)
    
    if player.Character and IsEnabled then
        createHighlight(player)
    end
end

local function updateDistances()
    for player, gui in pairs(DistanceLabels) do
        if gui and gui.Parent then
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
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
    IsEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayerConnections(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        if IsEnabled then
            setupPlayerConnections(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
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
    
    for player, _ in pairs(Highlights) do
        removeHighlight(player)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
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

function ESP:SetColor(color)
    ESP_COLOR = color
    for _, highlight in pairs(Highlights) do
        highlight.FillColor = color
        highlight.OutlineColor = color
    end
    for _, gui in pairs(DistanceLabels) do
        local label = gui:FindFirstChild("Distance")
        if label then
            label.TextColor3 = color
        end
    end
end

return ESP
