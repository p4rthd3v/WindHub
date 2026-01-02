--[[
    WindHub Phantom Forces Game Scanner V2
    Deep scans the ENTIRE game to find where characters are stored
]]

local Scanner = {}
Scanner.__index = Scanner

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local DEBUG = true

local CachedCharacterFolder = nil
local CachedCharacters = {}

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF Scanner]", ...)
    end
end

local function findAllHumanoids()
    debugPrint("=== DEEP SCANNING FOR ALL HUMANOIDS ===")
    local found = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") then
            local parent = obj.Parent
            local grandparent = parent and parent.Parent
            local path = ""
            
            if grandparent then
                path = grandparent.Name .. "/" .. parent.Name
            elseif parent then
                path = parent.Name
            end
            
            debugPrint("HUMANOID FOUND:", parent and parent.Name or "nil", "at", path)
            debugPrint("  Parent class:", parent and parent.ClassName or "nil")
            debugPrint("  Grandparent:", grandparent and grandparent.Name or "nil", grandparent and grandparent.ClassName or "")
            debugPrint("  Health:", obj.Health, "/", obj.MaxHealth)
            
            if parent and parent:IsA("Model") then
                table.insert(found, {
                    Humanoid = obj,
                    Character = parent,
                    Container = grandparent,
                    Name = parent.Name
                })
            end
        end
    end
    
    debugPrint("Total humanoids found:", #found)
    return found
end

local function findCharacterContainer()
    debugPrint("=== FINDING CHARACTER CONTAINER ===")
    
    local humanoids = findAllHumanoids()
    local containerCounts = {}
    
    for _, data in ipairs(humanoids) do
        if data.Container then
            local name = data.Container.Name
            containerCounts[name] = (containerCounts[name] or 0) + 1
        end
    end
    
    local bestContainer = nil
    local bestCount = 0
    
    for name, count in pairs(containerCounts) do
        debugPrint("Container:", name, "has", count, "characters")
        if count > bestCount then
            bestCount = count
            bestContainer = name
        end
    end
    
    if bestContainer then
        debugPrint("Most likely character container:", bestContainer)
        
        local container = Workspace:FindFirstChild(bestContainer)
        if not container then
            for _, child in ipairs(Workspace:GetChildren()) do
                if child.Name == bestContainer then
                    container = child
                    break
                end
            end
        end
        
        CachedCharacterFolder = container
        return container
    end
    
    return nil
end

local function getCharacterFromContainer(playerName)
    if not CachedCharacterFolder then
        findCharacterContainer()
    end
    
    if CachedCharacterFolder then
        for _, child in ipairs(CachedCharacterFolder:GetChildren()) do
            if child:IsA("Model") and child.Name == playerName then
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return child
                end
            end
        end
    end
    
    return nil
end

local function findCharacterByHumanoidScan(playerName)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local parent = obj.Parent
            if parent and parent:IsA("Model") and parent.Name == playerName then
                return parent
            end
        end
    end
    return nil
end

function Scanner.Init()
    debugPrint("=== PHANTOM FORCES SCANNER V2 INITIALIZING ===")
    debugPrint("LocalPlayer:", LocalPlayer.Name)
    
    debugPrint("")
    debugPrint("=== WORKSPACE TOP LEVEL ===")
    for _, child in ipairs(Workspace:GetChildren()) do
        local childCount = 0
        if child:IsA("Folder") or child:IsA("Model") then
            childCount = #child:GetChildren()
        end
        debugPrint(child.ClassName, ":", child.Name, childCount > 0 and ("(" .. childCount .. " children)") or "")
    end
    
    debugPrint("")
    findCharacterContainer()
    
    debugPrint("")
    debugPrint("=== TESTING PLAYER LOOKUP ===")
    for _, player in ipairs(Players:GetPlayers()) do
        local char = Scanner.GetCharacter(player)
        if char then
            debugPrint("SUCCESS: Found character for", player.Name)
            local root = Scanner.GetRootPart(char)
            debugPrint("  RootPart:", root and root.Name or "None")
        else
            debugPrint("FAILED: No character for", player.Name)
        end
    end
    
    debugPrint("")
    debugPrint("=== LOCAL PLAYER CHARACTER ===")
    local myChar = Scanner.GetCharacter(LocalPlayer)
    if myChar then
        debugPrint("Local character found!")
        debugPrint("Parts in character:")
        for _, part in ipairs(myChar:GetChildren()) do
            debugPrint("  -", part.Name, "(" .. part.ClassName .. ")")
        end
    else
        debugPrint("Local character NOT found via name lookup")
        debugPrint("Trying camera subject...")
        local camera = Workspace.CurrentCamera
        if camera and camera.CameraSubject then
            local subject = camera.CameraSubject
            debugPrint("Camera subject:", subject.Name, subject.ClassName)
            if subject:IsA("Humanoid") then
                local char = subject.Parent
                debugPrint("Found character via camera:", char.Name)
                CachedCharacters[LocalPlayer] = char
            end
        end
    end
    
    debugPrint("")
    debugPrint("=== SCANNER V2 COMPLETE ===")
    
    return true
end

function Scanner.GetCharacter(player)
    if CachedCharacters[player] then
        local cached = CachedCharacters[player]
        local humanoid = cached:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 and cached.Parent then
            return cached
        else
            CachedCharacters[player] = nil
        end
    end
    
    if player == LocalPlayer then
        local camera = Workspace.CurrentCamera
        if camera and camera.CameraSubject then
            local subject = camera.CameraSubject
            if subject:IsA("Humanoid") and subject.Parent then
                CachedCharacters[player] = subject.Parent
                return subject.Parent
            end
        end
    end
    
    local char = getCharacterFromContainer(player.Name)
    if char then
        CachedCharacters[player] = char
        return char
    end
    
    char = findCharacterByHumanoidScan(player.Name)
    if char then
        CachedCharacters[player] = char
        return char
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            CachedCharacters[player] = player.Character
            return player.Character
        end
    end
    
    return nil
end

function Scanner.GetRootPart(character)
    if not character then return nil end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return root end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RootPart then
        return humanoid.RootPart
    end
    
    root = character:FindFirstChild("Torso")
    if root then return root end
    
    root = character:FindFirstChild("UpperTorso")
    if root then return root end
    
    root = character:FindFirstChild("LowerTorso")
    if root then return root end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "Head" then
            return part
        end
    end
    
    return nil
end

function Scanner.GetHead(character)
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

function Scanner.IsEnemy(player)
    return player ~= LocalPlayer
end

function Scanner.GetTeamColor(player)
    return Color3.fromRGB(255, 75, 75)
end

function Scanner.RefreshCache()
    CachedCharacters = {}
    CachedCharacterFolder = nil
    findCharacterContainer()
end

function Scanner.GetAllPlayers()
    local players = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = Scanner.GetCharacter(player)
            if char then
                table.insert(players, {
                    Player = player,
                    Character = char,
                    IsEnemy = Scanner.IsEnemy(player)
                })
            end
        end
    end
    
    return players
end

function Scanner.DebugPlayer(player)
    debugPrint("=== DEBUG PLAYER:", player.Name, "===")
    
    local char = Scanner.GetCharacter(player)
    debugPrint("Character found:", char and "Yes" or "No")
    
    if char then
        debugPrint("Character parent:", char.Parent and char.Parent.Name or "nil")
        
        local root = Scanner.GetRootPart(char)
        debugPrint("RootPart:", root and root.Name or "No")
        
        local head = Scanner.GetHead(char)
        debugPrint("Head:", head and "Yes" or "No")
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            debugPrint("Humanoid Health:", humanoid.Health)
        end
        
        debugPrint("All parts:")
        for _, part in ipairs(char:GetChildren()) do
            debugPrint("  -", part.Name, "(" .. part.ClassName .. ")")
        end
    end
end

return Scanner
