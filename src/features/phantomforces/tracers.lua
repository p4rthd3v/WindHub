--[[
    WindHub Phantom Forces Tracers V3
    Works with obfuscated character names
    Draws lines to all enemy characters
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

local DEBUG = true

local TRACER_COLOR = Color3.fromRGB(56, 189, 248)
local TRACER_THICKNESS = 2
local TRACER_TRANSPARENCY = 0.3

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF Tracers]", ...)
    end
end

local function createTracer(character)
    if not character then return end
    if TracerLines[character] then return end
    
    debugPrint("Creating tracer for:", character.Name)
    
    local beam = Instance.new("Part")
    beam.Name = "WindHubTracer"
    beam.Anchored = true
    beam.CanCollide = false
    beam.CanQuery = false
    beam.CanTouch = false
    beam.Material = Enum.Material.Neon
    beam.Color = TRACER_COLOR
    beam.Transparency = TRACER_TRANSPARENCY
    beam.CastShadow = false
    beam.Parent = Workspace
    
    TracerLines[character] = beam
end

local function removeTracer(character)
    if TracerLines[character] then
        pcall(function()
            TracerLines[character]:Destroy()
        end)
        TracerLines[character] = nil
    end
end

local function updateTracers()
    if not Scanner then return end
    if not IsEnabled then return end
    
    local myChar = Scanner.GetMyCharacter()
    if not myChar then return end
    
    local myRoot = Scanner.GetRootPart(myChar)
    if not myRoot then return end
    
    local myPos = myRoot.Position
    
    local enemies = Scanner.GetAllEnemyCharacters()
    
    for _, character in ipairs(enemies) do
        if not TracerLines[character] then
            createTracer(character)
        end
    end
    
    local toRemove = {}
    for character, beam in pairs(TracerLines) do
        local stillExists = false
        for _, enemy in ipairs(enemies) do
            if enemy == character then
                stillExists = true
                break
            end
        end
        
        if not stillExists then
            table.insert(toRemove, character)
        end
    end
    
    for _, character in ipairs(toRemove) do
        removeTracer(character)
    end
    
    for character, beam in pairs(TracerLines) do
        if beam and beam.Parent then
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
        end
    end
end

function Tracers:Enable()
    if IsEnabled then return end
    debugPrint("Enabling Tracers V3...")
    
    IsEnabled = true
    
    Scanner = loadModule("features/phantomforces/scanner.lua")
    if Scanner then
        debugPrint("Scanner loaded!")
        Scanner.Init()
    else
        debugPrint("ERROR: Failed to load scanner!")
        return
    end
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateTracers()
        end
    end)
    
    task.spawn(function()
        while IsEnabled do
            Scanner.RefreshAll()
            task.wait(1)
        end
    end)
    
    debugPrint("Tracers V3 Enabled!")
end

function Tracers:Disable()
    debugPrint("Disabling Tracers...")
    IsEnabled = false
    
    local toRemove = {}
    for character, _ in pairs(TracerLines) do
        table.insert(toRemove, character)
    end
    
    for _, character in ipairs(toRemove) do
        removeTracer(character)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
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
