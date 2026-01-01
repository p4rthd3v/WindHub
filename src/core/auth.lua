--[[
    WindHub Authentication System
    Handles key verification securely
]]

local Auth = {}
Auth.__index = Auth

local GITHUB_RAW = "https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/"

local KeyConfig = nil
local Attempts = 0
local LastAttemptTime = 0

local function fetchConfig()
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. "config/keys.lua")
    end)
    
    if success and result then
        local fn, err = loadstring(result)
        if fn then
            KeyConfig = fn()
            return true
        end
    end
    return false
end

local function hashKey(key)
    local hash = 0
    for i = 1, #key do
        hash = (hash * 31 + string.byte(key, i)) % 2147483647
    end
    return hash
end

function Auth:Init()
    return fetchConfig()
end

function Auth:GetSettings()
    if not KeyConfig then
        fetchConfig()
    end
    return KeyConfig and KeyConfig.Settings or { MaxAttempts = 5, CooldownSeconds = 300 }
end

function Auth:GetAttempts()
    return Attempts
end

function Auth:IsOnCooldown()
    local settings = self:GetSettings()
    if Attempts >= settings.MaxAttempts then
        local elapsed = os.time() - LastAttemptTime
        if elapsed < settings.CooldownSeconds then
            return true, settings.CooldownSeconds - elapsed
        else
            Attempts = 0
        end
    end
    return false, 0
end

function Auth:ValidateKey(inputKey)
    if not KeyConfig then
        if not fetchConfig() then
            return false, "Failed to fetch key configuration"
        end
    end
    
    local onCooldown, remaining = self:IsOnCooldown()
    if onCooldown then
        return false, "Too many attempts. Try again in " .. remaining .. " seconds"
    end
    
    local inputClean = string.upper(string.gsub(inputKey, "%s+", ""))
    
    -- Check Developer Keys
    if KeyConfig.DeveloperKeys then
        for _, devKey in ipairs(KeyConfig.DeveloperKeys) do
            local validClean = string.upper(string.gsub(devKey, "%s+", ""))
            
            if hashKey(inputClean) == hashKey(validClean) and inputClean == validClean then
                Attempts = 0
                return true, "Developer Access Granted", true
            end
        end
    end

    -- Check Validation Keys
    for _, validKey in ipairs(KeyConfig.ValidKeys) do
        local validClean = string.upper(string.gsub(validKey, "%s+", ""))
        
        if hashKey(inputClean) == hashKey(validClean) and inputClean == validClean then
            Attempts = 0
            return true, "Key validated successfully", false
        end
    end
    
    Attempts = Attempts + 1
    LastAttemptTime = os.time()
    
    local settings = self:GetSettings()
    local remaining = settings.MaxAttempts - Attempts
    
    if remaining <= 0 then
        return false, "Too many attempts. Locked for " .. settings.CooldownSeconds .. " seconds"
    end
    
    return false, "Invalid key. " .. remaining .. " attempts remaining"
end

function Auth:GetKeyLink()
    return "https://linkvertise.com/YOUR_LINK_HERE"
end

return Auth
