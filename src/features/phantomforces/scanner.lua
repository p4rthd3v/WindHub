--[[
    WindHub Phantom Forces Game Scanner
    Scans and analyzes the game structure to find players, teams, and characters
    Provides utility functions for other PF features
]]

local Scanner = {}
Scanner.__index = Scanner

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local DEBUG = true

local GameData = {
    CharactersFolder = nil,
    PlayersFolder = nil,
    TeamsFolder = nil,
    CameraFolder = nil,
    ModelsFolder = nil,
    FoundLocations = {},
    PlayerCharacters = {},
    TeamInfo = {}
}

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF Scanner]", ...)
    end
end

local function scanFolder(folder, depth, maxDepth, path)
    depth = depth or 0
    maxDepth = maxDepth or 3
    path = path or folder.Name
    
    if depth > maxDepth then return end
    
    local results = {}
    
    for _, child in ipairs(folder:GetChildren()) do
        local childPath = path .. "/" .. child.Name
        local info = {
            Name = child.Name,
            ClassName = child.ClassName,
            Path = childPath
        }
        
        if child:IsA("Humanoid") then
            debugPrint("Found Humanoid at:", childPath)
            table.insert(GameData.FoundLocations, {Type = "Humanoid", Path = childPath, Object = child})
        end
        
        if child:IsA("Model") then
            local humanoid = child:FindFirstChildOfClass("Humanoid")
            if humanoid then
                debugPrint("Found Character Model at:", childPath)
                table.insert(GameData.FoundLocations, {Type = "Character", Path = childPath, Object = child})
            end
        end
        
        if child.Name:lower():find("character") or child.Name:lower():find("player") then
            debugPrint("Found potential player container:", childPath)
            table.insert(GameData.FoundLocations, {Type = "Container", Path = childPath, Object = child})
        end
        
        if child:IsA("Folder") or child:IsA("Model") then
            scanFolder(child, depth + 1, maxDepth, childPath)
        end
        
        table.insert(results, info)
    end
    
    return results
end

local function findCharacterInWorkspace(playerName)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == playerName then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                return obj
            end
        end
    end
    return nil
end

local function findAllCharacterLocations()
    local locations = {}
    
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        table.insert(locations, {
                            Location = folder.Name,
                            Model = model,
                            Name = model.Name
                        })
                    end
                end
            end
        end
    end
    
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                table.insert(locations, {
                    Location = "Workspace",
                    Model = model,
                    Name = model.Name
                })
            end
        end
    end
    
    return locations
end

function Scanner.Init()
    debugPrint("=== PHANTOM FORCES SCANNER INITIALIZING ===")
    debugPrint("LocalPlayer:", LocalPlayer.Name)
    debugPrint("LocalPlayer Team:", LocalPlayer.Team and LocalPlayer.Team.Name or "None")
    debugPrint("LocalPlayer Character:", LocalPlayer.Character and "Yes" or "No")
    
    debugPrint("")
    debugPrint("=== SCANNING WORKSPACE ===")
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") then
            debugPrint("Folder:", child.Name, "- Children:", #child:GetChildren())
        elseif child:IsA("Model") then
            local humanoid = child:FindFirstChildOfClass("Humanoid")
            debugPrint("Model:", child.Name, humanoid and "(HAS HUMANOID)" or "")
        end
    end
    
    debugPrint("")
    debugPrint("=== SCANNING REPLICATED STORAGE ===")
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        debugPrint("RS Child:", child.Name, "-", child.ClassName)
    end
    
    debugPrint("")
    debugPrint("=== SCANNING TEAMS ===")
    local Teams = game:GetService("Teams")
    for _, team in ipairs(Teams:GetTeams()) do
        debugPrint("Team:", team.Name, "- Color:", tostring(team.TeamColor))
        local players = team:GetPlayers()
        for _, p in ipairs(players) do
            debugPrint("  Player:", p.Name)
        end
    end
    
    debugPrint("")
    debugPrint("=== SCANNING ALL PLAYERS ===")
    for _, player in ipairs(Players:GetPlayers()) do
        local team = player.Team and player.Team.Name or "None"
        local char = player.Character
        local charLocation = "None"
        
        if char then
            charLocation = char.Parent and char.Parent.Name or "Unknown"
        else
            local found = findCharacterInWorkspace(player.Name)
            if found then
                charLocation = "Found in " .. (found.Parent and found.Parent.Name or "Workspace")
                char = found
            end
        end
        
        debugPrint("Player:", player.Name)
        debugPrint("  Team:", team)
        debugPrint("  Character:", char and "Yes" or "No")
        debugPrint("  Char Location:", charLocation)
        
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            debugPrint("  Has HumanoidRootPart:", root and "Yes" or "No")
            debugPrint("  Has Torso:", torso and "Yes" or "No")
            debugPrint("  Has Head:", head and "Yes" or "No")
            debugPrint("  Has Humanoid:", humanoid and "Yes" or "No")
            if humanoid then
                debugPrint("  Humanoid Health:", humanoid.Health, "/", humanoid.MaxHealth)
            end
        end
    end
    
    debugPrint("")
    debugPrint("=== FINDING ALL CHARACTER MODELS ===")
    local allChars = findAllCharacterLocations()
    for _, data in ipairs(allChars) do
        debugPrint("Character:", data.Name, "in", data.Location)
    end
    
    debugPrint("")
    debugPrint("=== CAMERA INFO ===")
    local camera = Workspace.CurrentCamera
    if camera then
        debugPrint("Camera Subject:", camera.CameraSubject and camera.CameraSubject.Name or "None")
        debugPrint("Camera Type:", tostring(camera.CameraType))
    end
    
    debugPrint("")
    debugPrint("=== SCANNER COMPLETE ===")
    
    return GameData
end

function Scanner.GetCharacter(player)
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return player.Character
        end
    end
    
    local found = findCharacterInWorkspace(player.Name)
    if found then
        local humanoid = found:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return found
        end
    end
    
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") then
            local model = folder:FindFirstChild(player.Name)
            if model and model:IsA("Model") then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return model
                end
            end
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
        if part:IsA("BasePart") then
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
    if not LocalPlayer.Team then return true end
    if not player.Team then return true end
    
    return LocalPlayer.Team ~= player.Team
end

function Scanner.GetTeamColor(player)
    if Scanner.IsEnemy(player) then
        return Color3.fromRGB(255, 75, 75)
    else
        return Color3.fromRGB(75, 175, 255)
    end
end

function Scanner.GetAllEnemies()
    local enemies = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Scanner.IsEnemy(player) then
            local char = Scanner.GetCharacter(player)
            if char then
                table.insert(enemies, {
                    Player = player,
                    Character = char
                })
            end
        end
    end
    
    return enemies
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
        debugPrint("RootPart found:", root and root.Name or "No")
        
        local head = Scanner.GetHead(char)
        debugPrint("Head found:", head and "Yes" or "No")
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            debugPrint("Humanoid Health:", humanoid.Health)
        end
        
        debugPrint("Parts in character:")
        for _, part in ipairs(char:GetChildren()) do
            debugPrint("  -", part.Name, "(" .. part.ClassName .. ")")
        end
    end
    
    debugPrint("Team:", player.Team and player.Team.Name or "None")
    debugPrint("Is Enemy:", Scanner.IsEnemy(player))
end

return Scanner
