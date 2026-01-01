--[[
    WindHub Baseplate Features
    Feature list for Baseplate game
    v1.1
]]

return {
    GameName = "Baseplate",
    GameIcon = "🏗️",
    Version = "1.1",
    
    Features = {
        {
            Name = "Speed Hack",
            Description = "Increase your walk speed",
            Category = "Movement",
            Module = "features/baseplate/speed.lua",
            Type = "slider",
            Default = 16,
            Min = 16,
            Max = 200,
        },
        {
            Name = "Player ESP",
            Description = "See all players through walls",
            Category = "Visual",
            Module = "features/baseplate/esp.lua",
            Type = "toggle",
        },
        {
            Name = "Teleport to Player",
            Description = "Teleport to any player in the game",
            Category = "Movement",
            Module = "features/baseplate/teleport.lua",
            Type = "dropdown",
        },
    },
}
