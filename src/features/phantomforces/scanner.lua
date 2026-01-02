--[[
    WindHub Phantom Forces Game Scanner V3
    Handles PF's obfuscated character names
    Characters are in "Ignore" folder with encoded names
]]

local Scanner = {}
Scanner.__index = Scanner

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local DEBUG = true

local MyCharacter = nil
local AllCharacters = {}
local IgnoreFolder = nil

local function debugPrint(...)
    if DEBUG then
        print("[WindHub PF Scanner]", ...)
    end
end

local function findIgnoreFolder()
    IgnoreFolder = Workspace:FindFirstChild("Ignore")
    if IgnoreFolder then
        debugPrint("Found Ignore folder with", #IgnoreFolder:GetChildren(), "children")
        return IgnoreFolder
    end
    
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") then
            local hasHumanoids = false
            for _, obj in ipairs(child:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                    hasHumanoids = true
                    break
                end
            end
            if hasHumanoids then
                debugPrint("Found character folder:", child.Name)
                IgnoreFolder = child
                return child
            end
        end
    end
    
    return nil
end

local function getMyCharacterFromCamera()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    
    local subject = camera.CameraSubject
    if not subject then return nil end
    
    if subject:IsA("Humanoid") then
        MyCharacter = subject.Parent
        debugPrint("Found my character via camera:", MyCharacter.Name)
        return MyCharacter
    elseif subject:IsA("BasePart") then
        MyCharacter = subject.Parent
        debugPrint("Found my character via camera part:", MyCharacter.Name)
        return MyCharacter
    end
    
    return nil
end

local function getAllCharacterModels()
    AllCharacters = {}
    
    if not IgnoreFolder then
        findIgnoreFolder()
    end
    
    if IgnoreFolder then
        for _, child in ipairs(IgnoreFolder:GetChildren()) do
            if child:IsA("Model") then
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(AllCharacters, child)
                end
            end
        end
    end
    
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child ~= IgnoreFolder then
            local humanoid = child:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local alreadyAdded = false
                for _, c in ipairs(AllCharacters) do
                    if c == child then
                        alreadyAdded = true
                        break
                    end
                end
                if not alreadyAdded then
                    table.insert(AllCharacters, child)
                end
            end
        end
    end
    
    debugPrint("Found", #AllCharacters, "total character models")
    return AllCharacters
end

function Scanner.Init()
    debugPrint("=== PHANTOM FORCES SCANNER V3 ===")
    debugPrint("This version handles obfuscated character names")
    debugPrint("")
    
    findIgnoreFolder()
    
    getMyCharacterFromCamera()
    
    getAllCharacterModels()
    
    debugPrint("")
    debugPrint("=== ALL FOUND CHARACTERS ===")
    for i, char in ipairs(AllCharacters) do
        local isMe = (char == MyCharacter)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        debugPrint(i .. ".", char.Name, isMe and "(THIS IS ME)" or "", "Health:", humanoid and humanoid.Health or 0)
    end
    
    debugPrint("")
    debugPrint("=== SCANNER V3 READY ===")
    
    return true
end

function Scanner.GetMyCharacter()
    if MyCharacter then
        local humanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 and MyCharacter.Parent then
            return MyCharacter
        end
    end
    
    return getMyCharacterFromCamera()
end

function Scanner.GetAllEnemyCharacters()
    getAllCharacterModels()
    getMyCharacterFromCamera()
    
    local enemies = {}
    
    for _, char in ipairs(AllCharacters) do
        if char ~= MyCharacter then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(enemies, char)
            end
        end
    end
    
    debugPrint("Found", #enemies, "enemy characters")
    return enemies
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

function Scanner.IsMyCharacter(character)
    if not MyCharacter then
        getMyCharacterFromCamera()
    end
    return character == MyCharacter
end

function Scanner.RefreshAll()
    debugPrint("Refreshing scanner...")
    findIgnoreFolder()
    getMyCharacterFromCamera()
    getAllCharacterModels()
end

return Scanner
