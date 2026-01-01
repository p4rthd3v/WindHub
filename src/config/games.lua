--[[
    WindHub Supported Games
    Add games here with their PlaceId and display info
    Status can be "Production" (default) or "Development" (requires dev key)
]]

return {
    Games = {
        ["168556275"] = {
            Name = "Baseplate",
            Icon = "🏗️",
            FeaturesPath = "features/baseplate/init.lua",
            Status = "Development",
        },
        ["292439477"] = {
            Name = "Phantom Forces",
            Icon = "🔫",
            FeaturesPath = "features/phantomforces/init.lua",
            Status = "Development",
        },
    },
    
    UnsupportedMessage = "This game is not currently supported by WindHub.",
}
