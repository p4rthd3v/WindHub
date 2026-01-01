--[[
    WindHub Baseplate Features
    Feature list for Baseplate game
]]

return {
    GameName = "Baseplate",
    GameIcon = "🏗️",
    
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
    },
}
