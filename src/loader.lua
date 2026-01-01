--[[
    WindHub Loader
    Main entry point for the script hub
]]

local WindHub = {}
WindHub.__index = WindHub

local GITHUB_RAW = "https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/"

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

local function loadMainHub()
    print("[WindHub] Loading modules...")
    
    local modules = {
        "modules/example.lua",
    }
    
    for _, modulePath in ipairs(modules) do
        local module = loadModule(modulePath)
        if module and type(module.Init) == "function" then
            module:Init()
        end
    end
    
    print("[WindHub] Loaded successfully!")
end

function WindHub:Init()
    print("[WindHub] Initializing...")
    
    local KeyUI = loadModule("ui/key_ui.lua")
    
    if KeyUI then
        KeyUI:Show(function()
            loadMainHub()
        end)
    else
        warn("[WindHub] Failed to load key UI, loading without verification...")
        loadMainHub()
    end
    
    return self
end

return WindHub:Init()
