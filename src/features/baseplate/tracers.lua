--[[
    WindHub Tracers Feature
    Draws lines from local player to all other players
]]

local Tracers = {}
Tracers.__index = Tracers

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local TracerLines = {}
local UpdateConnection = nil
local CharacterConnections = {}

local TRACER_COLOR = Color3.fromRGB(56, 189, 248)
local TRACER_THICKNESS = 2
local TRACER_TRANSPARENCY = 0.3

local function createTracer(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    if TracerLines[player] then
        TracerLines[player]:Destroy()
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
    beam.Parent = workspace
    
    TracerLines[player] = beam
end

local function removeTracer(player)
    if TracerLines[player] then
        TracerLines[player]:Destroy()
        TracerLines[player] = nil
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
    
    CharacterConnections[player] = player.CharacterAdded:Connect(function()
        if IsEnabled then
            task.wait(0.5)
            createTracer(player)
        end
    end)
    
    if player.Character and IsEnabled then
        createTracer(player)
    end
end

local function updateTracers()
    if not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local myPos = myRoot.Position
    
    for player, beam in pairs(TracerLines) do
        if beam and beam.Parent then
            local character = player.Character
            if character then
                local targetRoot = character:FindFirstChild("HumanoidRootPart")
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
    
    for player, _ in pairs(TracerLines) do
        removeTracer(player)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
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
        beam.Color = color
    end
end

function Tracers:SetThickness(thickness)
    TRACER_THICKNESS = thickness
end

return Tracers
