# 🌀 WindHub

A powerful, modular game enhancement hub for Roblox with a premium UI design.

## ✨ Features

- **🔐 Secure Key System** - Server-side key validation with developer access levels
- **🎮 Multi-Game Support** - Dynamic feature loading based on current game
- **🎨 Premium UI** - Clean, modern design with smooth animations
- **📦 Modular Architecture** - Easy to add new features and games
- **🖱️ Fully Draggable UI** - Drag the hub from anywhere on the window
- **📋 Per-Game Update Logs** - Each game gets its own changelog

## 🚀 Quick Start

Execute in your Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/loader.lua"))()
```

## 🎮 Supported Games

| Game | Status | Features |
|------|--------|----------|
| [Baseplate](https://www.roblox.com/games/168556275/Baseplate) | Development | Speed Hack, Player ESP, Tracers, Teleport |
| [Phantom Forces](https://www.roblox.com/games/292439477/Phantom-Forces) | Development | Player ESP (with Team Check), Tracers |

> **Note:** Games marked as "Development" require a developer key to access.

## 📋 Version History

### v1.2.0 (Jan 1, 2026)
- 🔫 Added Phantom Forces support
- 🖱️ Made entire UI draggable from any position
- 📋 Per-game update logs
- 🎛️ New toggle with dropdown control type
- 📁 Refactored features tab into modular components

### v1.1.0 (Jan 1, 2026)
- 👁️ Added Player ESP feature
- 📍 Added Player Tracers feature
- 🚀 Added Teleport to Player feature
- 🎮 Game detection system
- ⚡ Dynamic feature loading
- 🔧 Improved minimize animations

### v1.0.0 (Jan 1, 2026)
- 🎉 Initial release
- 🔐 Secure key system
- 🎨 Premium UI design
- 📦 Modular script loading

## 📁 Project Structure

```
WindHub/
├── src/
│   ├── loader.lua                    # Main entry point
│   ├── config/
│   │   ├── keys.lua                  # Key configuration (standard + dev keys)
│   │   └── games.lua                 # Supported games registry
│   ├── core/
│   │   ├── auth.lua                  # Authentication & key validation
│   │   └── game_detector.lua         # Game detection & status checking
│   ├── features/
│   │   ├── baseplate/                # Baseplate features
│   │   │   ├── init.lua              # Feature registry + update log
│   │   │   ├── speed.lua             # Speed hack
│   │   │   ├── esp.lua               # Player ESP
│   │   │   ├── tracers.lua           # Player tracers
│   │   │   └── teleport.lua          # Teleport to player
│   │   └── phantomforces/            # Phantom Forces features
│   │       ├── init.lua              # Feature registry + update log
│   │       ├── esp.lua               # ESP with team check
│   │       └── tracers.lua           # Player tracers
│   └── ui/
│       ├── key_ui.lua                # Key verification UI
│       ├── components/               # Shared UI components
│       │   ├── theme.lua             # Color & font definitions
│       │   └── toast.lua             # Toast notifications
│       └── hub/                      # Main hub UI
│           ├── init.lua              # Hub controller
│           ├── sidebar.lua           # Navigation sidebar
│           ├── topbar.lua            # Top bar with controls
│           └── tabs/
│               ├── home.lua          # Home tab with update logs
│               ├── settings.lua      # Settings tab
│               └── features/         # Features tab (modular)
│                   ├── init.lua      # Main controller
│                   └── controls/     # UI control components
│                       ├── toggle.lua
│                       ├── slider.lua
│                       ├── dropdown.lua
│                       └── toggle_dropdown.lua
└── README.md
```

## 🔑 Keys

### Standard Keys
- `WIND-BETA-2026-TEST`

### Developer Keys
- `WIND-DEV-MASTER-KEY`

> Developer keys grant access to games in "Development" status.

## 🎮 Adding New Games

1. Add the game to `src/config/games.lua` with PlaceId, name, icon, and status
2. Create a new folder in `src/features/[gamename]/`
3. Create `init.lua` with feature registry and update log
4. Add feature modules (esp.lua, tracers.lua, etc.)

## ⚠️ Disclaimer

This project is for educational purposes only. Use responsibly and in accordance with game terms of service.

---

Made with ❤️ by WindHub Team
