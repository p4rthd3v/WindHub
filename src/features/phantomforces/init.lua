--[[
    WindHub Phantom Forces Features
    Feature list for Phantom Forces game
    v1.0
]]

return {
    GameName = "Phantom Forces",
    GameIcon = "🔫",
    Version = "1.0",
    
    UpdateLog = {
        {
            version = "v1.0.0",
            date = "Jan 1, 2026",
            changes = {
                "🔫 Initial Phantom Forces support",
                "👁️ Added Player ESP with team check",
                "📍 Added Player Tracers",
            }
        },
    },
    
    Features = {
        {
            Name = "Player ESP",
            Description = "See players through walls with distance",
            Category = "Visual",
            Module = "features/phantomforces/esp.lua",
            Type = "toggle_dropdown",
            DropdownLabel = "Team Check",
            DropdownOptions = {"Off", "Enemies Only"},
            DropdownDefault = "Off",
        },
        {
            Name = "Player Tracers",
            Description = "Draw lines to all players",
            Category = "Visual",
            Module = "features/phantomforces/tracers.lua",
            Type = "toggle",
        },
    },
}
