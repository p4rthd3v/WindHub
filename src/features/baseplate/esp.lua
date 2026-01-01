--[[
    WindHub ESP Feature
    Highlights players through walls with outlines
]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local IsEnabled = false
local Highlights = {}
local UpdateConnection = nil

local ESP_COLOR = Color3.fromRGB(99, 102, 241)
local FILL_TRANSPARENCY = 0.8
local OUTLINE_TRANSPARENCY = 0

local function createHighlight(player)
    if player == LocalPlayer then return end
    if Highlights[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WindHubESP"
    highlight.Adornee = character
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = ESP_COLOR
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    Highlights[player] = highlight
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and IsEnabled then
                if not Highlights[player] or not Highlights[player].Parent then
                    createHighlight(player)
                end
            end
        end
    end
end

function ESP:Enable()
    IsEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        createHighlight(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        if IsEnabled then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if IsEnabled then
                    createHighlight(player)
                end
            end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    UpdateConnection = RunService.Heartbeat:Connect(function()
        if IsEnabled then
            updateESP()
        end
    end)
end

function ESP:Disable()
    IsEnabled = false
    
    for player, _ in pairs(Highlights) do
        removeHighlight(player)
    end
    
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end
end

function ESP:Toggle(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function ESP:IsEnabled()
    return IsEnabled
end

function ESP:SetColor(color)
    ESP_COLOR = color
    for _, highlight in pairs(Highlights) do
        highlight.FillColor = color
        highlight.OutlineColor = color
    end
end

return ESP
