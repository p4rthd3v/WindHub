--[[
    WindHub Phantom Forces Tracers Feature
    Draws lines from local player to all other players
    Works with PF's character system
]]

local Tracers = {}
Tracers.__index = Tracers

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local TracerLines = {}
local UpdateConnection = nil
local CharacterConnections = {}
local PlayerAddedConnection = nil
local PlayerRemovingConnection = nil

local TRACER_COLOR = Color3.fromRGB(56, 189, 248)
local TRACER_THICKNESS = 2
local TRACER_TRANSPARENCY = 0.3

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

local function createTracer(player)
    if player == LocalPlayer then return end
    
    local character = getCharacter(player)
    if not character then return end
    
    if TracerLines[player] then
        pcall(function() TracerLines[player]:Destroy() end)
    end
    
    local beam = Instance.new("Part")
    beam.Name = "WindHubTracer_" .. player.Name
    beam.Anchored = true
    beam.CanCollide = false
    beam.CanQuery = false
    beam.CanTouch = false
    beam.Material = Enum.Material.Neon
    beam.Color = TRACER_COLOR
    beam.Transparency = TRACER_TRANSPARENCY
    beam.CastShadow = false
    beam.Parent = Workspace
    
    TracerLines[player] = beam
end

local function removeTracer(player)
    if TracerLines[player] then
        pcall(function()
            TracerLines[player]:Destroy()
        end)
        TracerLines[player] = nil
    end
    if CharacterConnections[player] then
        pcall(function()
            CharacterConnections[player]:Disconnect()
        end)
        CharacterConnections[player] = nil
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
            createTracer(player)
        end
    end)
    
    local character = getCharacter(player)
    if character and IsEnabled then
        task.spawn(function()
            task.wait(0.5)
            createTracer(player)
        end)
    end
end

local function updateTracers()
    local myChar = getCharacter(LocalPlayer)
    if not myChar then return end
    
    local myRoot = getRootPart(myChar)
    if not myRoot then return end
    
    local myPos = myRoot.Position
    
    for player, beam in pairs(TracerLines) do
        if beam and beam.Parent then
            local character = getCharacter(player)
            if character then
                local targetRoot = getRootPart(character)
                if targetRoot then
                    local targetPos = targetRoot.Position
                    local distance = (targetPos - myPos).Magnitude
                    local midpoint = (myPos + targetPos) / 2
                    
                    beam.Size = Vector3.new(TRACER_THICKNESS / 10, TRACER_THICKNESS / 10, distance)
                    beam.CFrame = CFrame.lookAt(midpoint, targetPos)
                else
                    beam.Size = Vector3.new(0, 0, 0)
                end
            else
                beam.Size = Vector3.new(0, 0, 0)
            end
        end
    end
end

function Tracers:Enable()
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
        removeTracer(player)
    end)
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateTracers()
        end
    end)
end

function Tracers:Disable()
    IsEnabled = false
    
    local playersToRemove = {}
    for player, _ in pairs(TracerLines) do
        table.insert(playersToRemove, player)
    end
    
    for _, player in ipairs(playersToRemove) do
        removeTracer(player)
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

function Tracers:Toggle(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function Tracers:IsEnabled()
    return IsEnabled
end

function Tracers:SetColor(color)
    TRACER_COLOR = color
    for _, beam in pairs(TracerLines) do
        pcall(function()
            beam.Color = color
        end)
    end
end

function Tracers:SetThickness(thickness)
    TRACER_THICKNESS = thickness
end

return Tracers
