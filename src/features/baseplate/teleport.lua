--[[
    WindHub Teleport Feature
    Teleport to selected player
]]

local Teleport = {}
Teleport.__index = Teleport

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Teleport:GetPlayerList()
    local playerList = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, {
                Name = player.Name,
                DisplayName = player.DisplayName,
                UserId = player.UserId,
            })
        end
    end
    
    return playerList
end

function Teleport:ToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    
    if not targetPlayer then
        return false, "Player not found"
    end
    
    if not targetPlayer.Character then
        return false, "Player has no character"
    end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return false, "Target has no HumanoidRootPart"
    end
    
    if not LocalPlayer.Character then
        return false, "You have no character"
    end
    
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        return false, "You have no HumanoidRootPart"
    end
    
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    
    return true, "Teleported to " .. targetPlayer.DisplayName
end

function Teleport:ToPosition(position)
    if not LocalPlayer.Character then
        return false, "You have no character"
    end
    
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        return false, "You have no HumanoidRootPart"
    end
    
    myRoot.CFrame = CFrame.new(position)
    
    return true, "Teleported to position"
end

return Teleport
