# VeenzeGui — Implementation & Loadstring Guide

This guide explains how to structure your repository, set up automatic game detection using Place IDs, and format standalone external scripts when working with the **VeenzeGui** library.

---

## 1. Master Bootloader Setup

To handle multiple games within a single script, use a **Master Bootloader**. This script checks the player's current `game.PlaceId` against a list of supported games. 

* If the game is supported, it pulls and runs a game-specific script using `loadstring`.
* If the game is not supported, it falls back to a clean text interface stating `"this game isnt supported doofus"`.

### The Bootloader Script (`main.lua`)

```lua
-- Initialize the core UI library
local VeenzeLib = loadstring(game:HttpGet("[https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua](https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua)"))()
local Window = VeenzeLib:CreateWindow("Universal Hub")

-- Configuration Mapping: Place ID to its dedicated standalone script URL
local SupportedGames = {
    [275391513]  = "[https://raw.githubusercontent.com/username/repo/main/games/blox_fruits.lua](https://raw.githubusercontent.com/username/repo/main/games/blox_fruits.lua)",
    [6872265039] = "[https://raw.githubusercontent.com/username/repo/main/games/bedwars.lua](https://raw.githubusercontent.com/username/repo/main/games/bedwars.lua)"
}

local CurrentPlaceId = game.PlaceId

if SupportedGames[CurrentPlaceId] then
    -- 1. Pass the initialized Window context to a global variable
    _G.WindowContext = Window
    
    -- 2. Fetch and execute the game-specific standalone script
    local success, err = pcall(function()
        loadstring(game:HttpGet(SupportedGames[CurrentPlaceId]))()
    end)
    
    if not success then
        warn("Failed to load game script: " .. tostring(err))
    end
else
    -- Fallback: Display an unsupported error tab if the Place ID isn't registered
    local ErrorTab = Window:CreateTab("Unsupported")
    ErrorTab:CreateButton("this game isnt supported doofus", function()
        -- Optional callback action
    end)
end
