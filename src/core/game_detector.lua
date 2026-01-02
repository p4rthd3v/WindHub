--[[
    WindHub Game Detector
    Detects current game and returns game info
]]

local GameDetector = {}
GameDetector.__index = GameDetector

local GITHUB_RAW = "https://raw.githubusercontent.com/p4rthd3v/WindHub/main/src/"

local GamesConfig = nil
local CurrentGame = nil

local function fetch(path)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. path)
    end)
    if success then return result end
    return nil
end

local function loadConfig()
    local source = fetch("config/games.lua")
    if source then
        local fn = loadstring(source)
        if fn then
            GamesConfig = fn()
            return true
        end
    end
    return false
end

local IsDev = false

function GameDetector:Init(isUserDev)
    IsDev = isUserDev or false
    
    if not loadConfig() then
        warn("[WindHub] Failed to load games config")
        return false
    end
    
    local placeId = tostring(game.PlaceId)
    
    if GamesConfig.Games[placeId] then
        CurrentGame = GamesConfig.Games[placeId]
        CurrentGame.PlaceId = placeId
        
        -- Check if game is in Development and if user is Dev
        if CurrentGame.Status == "Development" and not IsDev then
            CurrentGame.Supported = false
            CurrentGame.Message = "This game is currently in Development. Developer access required."
        else
            CurrentGame.Supported = true
        end
    else
        CurrentGame = {
            Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game",
            PlaceId = placeId,
            Supported = false,
            Message = GamesConfig.UnsupportedMessage,
        }
    end
    
    return true
end

function GameDetector:GetCurrentGame()
    return CurrentGame
end

function GameDetector:IsSupported()
    return CurrentGame and CurrentGame.Supported == true
end

function GameDetector:GetFeaturesPath()
    if CurrentGame and CurrentGame.FeaturesPath then
        return CurrentGame.FeaturesPath
    end
    return nil
end

function GameDetector:GetGameName()
    if CurrentGame then
        return CurrentGame.Name
    end
    return "Unknown"
end

function GameDetector:GetGameIcon()
    if CurrentGame and CurrentGame.Icon then
        return CurrentGame.Icon
    end
    return "🎮"
end

return GameDetector
