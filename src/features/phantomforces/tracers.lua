--[[
    WindHub Phantom Forces Tracers Feature
    Uses Scanner module for robust character detection
    Debug mode enabled for troubleshooting
]]

local Tracers = {}
Tracers.__index = Tracers

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
local TracerLines = {}
local UpdateConnection = nil
local CharacterConnections = {}
local PlayerAddedConnection = nil
local PlayerRemovingConnection = nil

local DEBUG = true

local TRACER_COLOR = Color3.fromRGB(56, 189, 248)
local TRACER_THICKNESS = 2
local TRACER_TRANSPARENCY = 0.3

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF Tracers]", ...)
    end
end

local function createTracer(player)
    if player == LocalPlayer then return end
    if not Scanner then
        debugPrint("Scanner not loaded!")
        return
    end
    
    local character = Scanner.GetCharacter(player)
    if not character then
        debugPrint("No character for tracer:", player.Name)
        return
    end
    
    debugPrint("Creating tracer for:", player.Name)
    
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
    debugPrint("Tracer created for:", player.Name)
end

local function removeTracer(player)
    if TracerLines[player] then
        pcall(function()
            TracerLines[player]:Destroy()
        end)
        TracerLines[player] = nil
        debugPrint("Tracer removed for:", player.Name)
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
        debugPrint("CharacterAdded for tracer:", player.Name)
        if IsEnabled then
            task.wait(1.5)
            createTracer(player)
        end
    end)
    
    if IsEnabled then
        task.spawn(function()
            task.wait(0.5)
            createTracer(player)
        end)
    end
end

local function updateTracers()
    if not Scanner then return end
    
    local myChar = Scanner.GetCharacter(LocalPlayer)
    if not myChar then return end
    
    local myRoot = Scanner.GetRootPart(myChar)
    if not myRoot then return end
    
    local myPos = myRoot.Position
    
    for player, beam in pairs(TracerLines) do
        if beam and beam.Parent then
            local character = Scanner.GetCharacter(player)
            if character then
                local targetRoot = Scanner.GetRootPart(character)
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

local function periodicScan()
    if not IsEnabled then return end
    if not Scanner then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local hasTracer = TracerLines[player] ~= nil
            local character = Scanner.GetCharacter(player)
            
            if character and not hasTracer then
                debugPrint("Periodic scan found new character:", player.Name)
                createTracer(player)
            elseif not character and hasTracer then
                debugPrint("Periodic scan removing dead/missing:", player.Name)
                removeTracer(player)
            end
        end
    end
end

function Tracers:Enable()
    if IsEnabled then return end
    debugPrint("Enabling Tracers...")
    
    IsEnabled = true
    
    Scanner = loadModule("features/phantomforces/scanner.lua")
    if Scanner then
        debugPrint("Scanner loaded!")
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
        removeTracer(player)
    end)
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateTracers()
        end
    end)
    
    task.spawn(function()
        while IsEnabled do
            periodicScan()
            task.wait(2)
        end
    end)
    
    debugPrint("Tracers Enabled!")
end

function Tracers:Disable()
    debugPrint("Disabling Tracers...")
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
    
    debugPrint("Tracers Disabled!")
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
