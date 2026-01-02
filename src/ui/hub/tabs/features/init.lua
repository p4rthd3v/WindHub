--[[
    WindHub Features Tab
    Dynamic feature loading based on current game
    Split into modular control components
]]

local FeaturesTab = {}
FeaturesTab.__index = FeaturesTab

local GITHUB_RAW = "https://raw.githubusercontent.com/p4rthd3v/WindHub/main/src/"

local Theme = nil
local Container = nil
local LoadedModules = {}
local FeatureElements = {}

local Toggle = nil
local Slider = nil
local Dropdown = nil
local ToggleDropdown = nil

local function fetch(path)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. path)
    end)
    if success then return result end
    return nil
end

local function loadModule(path)
    local source = fetch(path)
    if source then
        local fn = loadstring(source)
        if fn then return fn() end
    end
    return nil
end

local function loadControls()
    Toggle = loadModule("ui/hub/tabs/features/controls/toggle.lua")
    Slider = loadModule("ui/hub/tabs/features/controls/slider.lua")
    Dropdown = loadModule("ui/hub/tabs/features/controls/dropdown.lua")
    ToggleDropdown = loadModule("ui/hub/tabs/features/controls/toggle_dropdown.lua")
end

function FeaturesTab:Create(parent, theme, gameDetector)
    Theme = theme
    
    loadControls()
    
    Container = Instance.new("ScrollingFrame")
    Container.Name = "FeaturesTab"
    Container.Size = UDim2.new(1, -180, 1, -45)
    Container.Position = UDim2.new(0, 180, 0, 45)
    Container.BackgroundColor3 = Theme.Colors.Background
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Theme.Colors.Primary
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.Visible = false
    Container.Parent = parent
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = Container
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = Container
    
    if not gameDetector or not gameDetector:IsSupported() then
        local unsupportedLabel = Instance.new("TextLabel")
        unsupportedLabel.Name = "Unsupported"
        unsupportedLabel.Size = UDim2.new(1, 0, 0, 100)
        unsupportedLabel.BackgroundTransparency = 1
        
        local msg = "⚠️ This game is not supported.\nNo features available."
        if gameDetector then
            local gameInfo = gameDetector:GetCurrentGame()
            if gameInfo and gameInfo.Message then
                msg = "⚠️ " .. gameInfo.Message
            end
        end
        
        unsupportedLabel.Text = msg
        unsupportedLabel.TextColor3 = Theme.Colors.TextMuted
        unsupportedLabel.TextSize = 14
        unsupportedLabel.Font = Theme.Fonts.Body
        unsupportedLabel.TextWrapped = true
        unsupportedLabel.LayoutOrder = 1
        unsupportedLabel.Parent = Container
        
        return Container
    end
    
    local gameName = gameDetector:GetGameName()
    local gameIcon = gameDetector:GetGameIcon()
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = gameIcon .. " " .. gameName .. " Features"
    header.TextColor3 = Theme.Colors.Text
    header.TextSize = 16
    header.Font = Theme.Fonts.Title
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.Parent = Container
    
    local featuresPath = gameDetector:GetFeaturesPath()
    if featuresPath then
        local gameFeatures = loadModule(featuresPath)
        
        if gameFeatures and gameFeatures.Features then
            for i, feature in ipairs(gameFeatures.Features) do
                if feature.Type == "slider" and Slider then
                    Slider.Create(Container, feature, i + 1, Theme, loadModule, LoadedModules, FeatureElements)
                elseif feature.Type == "dropdown" and Dropdown then
                    Dropdown.Create(Container, feature, i + 1, Theme, loadModule, LoadedModules, FeatureElements)
                elseif feature.Type == "toggle_dropdown" and ToggleDropdown then
                    ToggleDropdown.Create(Container, feature, i + 1, Theme, loadModule, LoadedModules, FeatureElements)
                elseif Toggle then
                    Toggle.Create(Container, feature, i + 1, Theme, loadModule, LoadedModules, FeatureElements)
                end
            end
        end
    end
    
    return Container
end

function FeaturesTab:Show()
    if Container then
        Container.Visible = true
    end
end

function FeaturesTab:Hide()
    if Container then
        Container.Visible = false
    end
end

function FeaturesTab:GetContainer()
    return Container
end

function FeaturesTab:Cleanup()
    for _, module in pairs(LoadedModules) do
        if module.Disable then
            module:Disable()
        elseif module.Toggle then
            module:Toggle(false)
        end
    end
    LoadedModules = {}
end

return FeaturesTab
