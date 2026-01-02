--[[
    WindHub Phantom Forces ESP V3
    Works with obfuscated character names
    Highlights all enemy characters found in game
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
local Highlights = {}
local DistanceLabels = {}
local UpdateConnection = nil
local ScanConnection = nil

local DEBUG = true

local ESP_COLOR = Color3.fromRGB(255, 75, 75)
local FILL_TRANSPARENCY = 0.7
local OUTLINE_TRANSPARENCY = 0

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF ESP]", ...)
    end
end

local function getDistance(position)
    if not Scanner then return 0 end
    
    local myChar = Scanner.GetMyCharacter()
    if not myChar then return 0 end
    
    local myRoot = Scanner.GetRootPart(myChar)
    if not myRoot then return 0 end
    
    return math.floor((myRoot.Position - position).Magnitude)
end

local function createDistanceLabel(character)
    if not Scanner then return nil end
    if not character then return nil end
    
    local head = Scanner.GetHead(character)
    if not head then
        local root = Scanner.GetRootPart(character)
        if root then
            head = root
        else
            return nil
        end
    end
    
    local existing = character:FindFirstChild("WindHubDistance")
    if existing then existing:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "WindHubDistance"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    billboard.Parent = character
    
    local label = Instance.new("TextLabel")
    label.Name = "Distance"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "0m"
    label.TextColor3 = ESP_COLOR
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    return billboard
end

local function removeHighlight(character)
    if Highlights[character] then
        pcall(function()
            Highlights[character]:Destroy()
        end)
        Highlights[character] = nil
    end
    if DistanceLabels[character] then
        pcall(function()
            DistanceLabels[character]:Destroy()
        end)
        DistanceLabels[character] = nil
    end
end

local function createHighlight(character)
    if not character then return end
    if not Scanner then return end
    
    if Scanner.IsMyCharacter(character) then
        debugPrint("Skipping my own character")
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        debugPrint("Skipping dead/no humanoid:", character.Name)
        return
    end
    
    if Highlights[character] then
        return
    end
    
    debugPrint("Creating highlight for:", character.Name)
    
    local existing = character:FindFirstChild("WindHubESP")
    if existing then existing:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WindHubESP"
    highlight.Adornee = character
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = ESP_COLOR
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    Highlights[character] = highlight
    
    local distanceGui = createDistanceLabel(character)
    if distanceGui then
        DistanceLabels[character] = distanceGui
    end
    
    debugPrint("Highlight created for:", character.Name)
end

local function updateHighlights()
    if not Scanner then return end
    if not IsEnabled then return end
    
    local enemies = Scanner.GetAllEnemyCharacters()
    
    for _, character in ipairs(enemies) do
        if not Highlights[character] then
            createHighlight(character)
        end
    end
    
    local toRemove = {}
    for character, highlight in pairs(Highlights) do
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
        removeHighlight(character)
    end
end

local function updateDistances()
    if not Scanner then return end
    
    for character, gui in pairs(DistanceLabels) do
        if gui and gui.Parent then
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

function ESP:Enable()
    if IsEnabled then return end
    debugPrint("Enabling ESP V3...")
    
    IsEnabled = true
    
    Scanner = loadModule("features/phantomforces/scanner.lua")
    if Scanner then
        debugPrint("Scanner loaded!")
        Scanner.Init()
    else
        debugPrint("ERROR: Failed to load scanner!")
        return
    end
    
    updateHighlights()
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateDistances()
        end
    end)
    
    task.spawn(function()
        while IsEnabled do
            Scanner.RefreshAll()
            updateHighlights()
            task.wait(1)
        end
    end)
    
    debugPrint("ESP V3 Enabled!")
end

function ESP:Disable()
    debugPrint("Disabling ESP...")
    IsEnabled = false
    
    local toRemove = {}
    for character, _ in pairs(Highlights) do
        table.insert(toRemove, character)
    end
    
    for _, character in ipairs(toRemove) do
        removeHighlight(character)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
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
    debugPrint("Team check not applicable in PF (obfuscated names)")
end

function ESP:SetColor(color)
    ESP_COLOR = color
    for character, highlight in pairs(Highlights) do
        pcall(function()
            highlight.FillColor = color
            highlight.OutlineColor = color
        end)
    end
end

return ESP
