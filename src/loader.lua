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

function WindHub:Init()
    print("[WindHub] Initializing...")
    
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
    return self
end

return WindHub:Init()
