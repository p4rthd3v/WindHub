# 🌀 WindHub

A powerful, modular game enhancement hub for Roblox with a premium UI design.

## ✨ Features

- **🔐 Secure Key System** - Server-side key validation with rate limiting
- **🎮 Multi-Game Support** - Dynamic feature loading based on current game
- **🎨 Premium UI** - Clean, modern design with smooth animations
- **📦 Modular Architecture** - Easy to add new features and games

## 🚀 Quick Start

Execute in your Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/flipgag746-sudo/WindHub/main/src/loader.lua"))()
```

## 🎮 Supported Games

| Game | Features |
|------|----------|
| [Baseplate](https://www.roblox.com/games/168556275/Baseplate) | Speed Hack, Player ESP, Teleport to Player |

## 📋 Version History

### v1.1.0 (Jan 1, 2026)
- 👁️ Added Player ESP feature
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
│   ├── loader.lua              # Main entry point
│   ├── config/
│   │   ├── keys.lua            # Key configuration
│   │   └── games.lua           # Supported games
│   ├── core/
│   │   ├── auth.lua            # Authentication
│   │   └── game_detector.lua   # Game detection
│   ├── features/
│   │   └── baseplate/          # Baseplate features
│   │       ├── init.lua        # Feature registry
│   │       ├── speed.lua       # Speed hack
│   │       ├── esp.lua         # Player ESP
│   │       └── teleport.lua    # Teleport to player
│   └── ui/
│       ├── key_ui.lua          # Key verification UI
│       ├── components/         # Shared UI components
│       └── hub/                # Main hub UI
└── README.md
```

## 🔑 Valid Keys

- `WIND-BETA-2026-TEST`

## ⚠️ Disclaimer

This project is for educational purposes only. Use responsibly and in accordance with game terms of service.

---

Made with ❤️ by WindHub Team
