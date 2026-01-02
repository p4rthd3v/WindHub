--[[
    WindHub Loader
    Main entry point for the script hub
]]

local WindHub = {}
WindHub.__index = WindHub

local GITHUB_RAW = "https://raw.githubusercontent.com/p4rthd3v/WindHub/main/src/"

local function fetch(path)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. path)
    end)
    
    if success then
        return result
    else
        warn("[WindHub] Failed to fetch: " .. path)
        return nil
    end
end

local function loadModule(path)
    local source = fetch(path)
    if source then
        local fn, err = loadstring(source)
        if fn then
            return fn()
        else
            warn("[WindHub] Failed to load module: " .. path .. " - " .. tostring(err))
        end
    end
    return nil
end

local function loadMainHub(isDev)
    print("[WindHub] Loading hub..." .. (isDev and " (DEV MODE)" or ""))
    
    local Hub = loadModule("ui/hub/init.lua")
    
    if Hub then
        local success = Hub:Create(isDev)
        if success then
            print("[WindHub] Hub loaded successfully!")
        else
            warn("[WindHub] Failed to create hub")
        end
    else
        warn("[WindHub] Failed to load hub module")
    end
end

function WindHub:Init()
    print("[WindHub] Initializing...")
    
    local success, KeyUI = pcall(function()
        return loadModule("ui/key_ui.lua")
    end)
    
    if success and KeyUI then
        -- Updated to accept isDev argument
        KeyUI:Show(function(isDev)
            loadMainHub(isDev)
        end)
    else
        loadMainHub(false)
    end
    
    return self
end

return WindHub:Init()
