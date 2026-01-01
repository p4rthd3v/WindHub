--[[
    WindHub Speed Hack
    Modifies player walk speed
]]

local Speed = {}
Speed.__index = Speed

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DefaultSpeed = 16
local CurrentSpeed = 16
local IsEnabled = false

function Speed:SetSpeed(value)
    CurrentSpeed = value
    
    if IsEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = CurrentSpeed
        end
    end
end

function Speed:Enable()
    IsEnabled = true
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            DefaultSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = CurrentSpeed
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if IsEnabled then
            task.wait(0.5)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = CurrentSpeed
            end
        end
    end)
end

function Speed:Disable()
    IsEnabled = false
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = DefaultSpeed
        end
    end
end

function Speed:Toggle(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function Speed:GetCurrentSpeed()
    return CurrentSpeed
end

function Speed:IsEnabled()
    return IsEnabled
end

return Speed
