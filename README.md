# VeenzeGui — Implementation & Loadstring Guide

This guide explains how to structure your repository, set up automatic game detection using Place IDs, and format standalone external scripts when working with the **VeenzeGui** library.

---

## 1. Core Installation & Setup

To initialize the interface globally in any execution environment, load the main library straight from your raw GitHub URL repository branch. 

```markdown
[https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua](https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua)
```

### Initializing the Window
The root setup function accepts a single string value to define the main application title.
```lua
local VeenzeLib = loadstring(game:HttpGet("[https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua](https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua)"))()

-- Initialize Main Window Wrapper
local Window = VeenzeLib:CreateWindow("Your Hub Name")
```

---

## 2. Multi-Game Detection Strategy (Place ID Loader)

To handle multiple games within a single script, use a **Master Bootloader**. This script checks the player's current `game.PlaceId` against a list of supported games. 

* If the game is supported via its registered ID, it pulls and runs a game-specific script using `loadstring` while passing a standalone tab to it.
* If the game is not supported, it falls back to a clean text interface stating `"this game isnt supported doofus"`.

### The Bootloader Script (`main.lua`)

```lua
-- Initialize the core UI library
local VeenzeLib = loadstring(game:HttpGet("[https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua](https://raw.githubusercontent.com/crazy-invader135/VeenzeGui/main/Lib.lua)"))()
local Window = VeenzeLib:CreateWindow("Universal Hub")

-- Configuration Table mapping Place IDs to standalone source loadstrings
local SupportedGames = {
    [275391513]  = "[https://raw.githubusercontent.com/username/repo/main/games/blox_fruits.lua](https://raw.githubusercontent.com/username/repo/main/games/blox_fruits.lua)",
    [6872265039] = "[https://raw.githubusercontent.com/username/repo/main/games/bedwars.lua](https://raw.githubusercontent.com/username/repo/main/games/bedwars.lua)",
    [142823291]  = "[https://raw.githubusercontent.com/username/repo/main/games/mm2.lua](https://raw.githubusercontent.com/username/repo/main/games/mm2.lua)"
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
        -- Optional fallback action
    end)
end

-- Establish global interface metadata elements
Window:CreateSupportedGamesTab({
    {name = "Blox Fruits", status = "green", placeId = 275391513},
    {name = "BedWars", status = "green", placeId = 6872265039},
    {name = "Murder Mystery 2", status = "green", placeId = 142823291}
})

Window:SetCredits("Credits:\n\nUI lib made by: Veenze\n\nScript compiler: Developer")
```

---

## 3. Formatting Independent Module Scripts

When separating your modules into sub-files on your repository for a proper loadstring setup, you **must not** create a new window. Instead, capture the window reference you passed through `_G.WindowContext`. This allows the script to inject a dedicated tab seamlessly into the already existing menu frame.

### Format for `games/blox_fruits.lua`:
```lua
-- Retrieve the initialized core frame from the boot environment
local Window = _G.WindowContext

-- Double check that the context exists before creating components
if not Window then
    warn("Execution halted: Parent Window context reference missing.")
    return
end

-- Instantiate isolated module tab
local FruitTab = Window:CreateTab("Blox Fruits")

FruitTab:CreateToggle("Auto Farm Levels", false, function(state)
    _G.AutoFarm = state
    while _G.AutoFarm do
        print("Executing level harvesting sequence...")
        task.wait(1)
    end
end)

FruitTab:CreateSlider("Teleport Delay (ms)", 100, 1000, 500, function(value)
    print("Adjusted yield timer: ", value)
end)
```

### Format for `games/bedwars.lua`:
```lua
local Window = _G.WindowContext
if not Window then return end

local BedwarsTab = Window:CreateTab("BedWars Combat")

BedwarsTab:CreateToggle("KillAura", false, function(state)
    _G.KillAuraEnabled = state
    print("Aura active state: ", state)
end)

BedwarsTab:CreateDropdown("Target Priority", {"Closest", "Lowest Health", "Teams"}, function(selection)
    print("Priority modified: ", selection)
end)
```

---

## 4. Element API Reference

### Window Layout Components

#### `VeenzeLib:CreateWindow(title: string)`
Builds the primary window container. Instantiates the global background panels, theme outlines, configuration tabs, and drag mechanics.

#### `Window:CreateTab(tabName: string)`
Generates an independent sidebar entry button linked to an isolated page layout. Returns a method object dictionary to append controls to that canvas page.

#### `Window:CreateSupportedGamesTab(gamesData: table)`
Compiles and maps a status board displaying layout options for known supported configurations.
* **Format Requirements:**
```lua
  { name = "String", status = "green" | "yellow" | "red", placeId = number }
  ```

#### `Window:SetCredits(text: string)`
Modifies the text inside the dedicated static information pop-up card available via the sidebar menu footer interface.

---

### Page Input Controls

All control elements must be generated sequentially on individual return references from your instantiated tab objects:

```lua
local Tab = Window:CreateTab("Example Canvas")
```

#### Toggles
```lua
Tab:CreateToggle(name: string, default: boolean, callback: function)
```
* **Description:** Emits boolean updates when state parameters alternate. Uses linear position transitions on indicator nodes.

#### Buttons
```lua
Tab:CreateButton(name: string, callback: function)
```
* **Description:** Triggers instantaneous function code executions. Includes interactive click-flash frame tinting.

#### Sliders
```lua
Tab:CreateSlider(name: string, min: number, max: number, default: number, callback: function)
```
* **Description:** Linear interpolation scale modifier returning raw integer variables during input track interaction.

#### Dropdowns
```lua
Tab:CreateDropdown(name: string, options: table, callback: function)
```

(this may or may not be ai bc im too lazy to make doccumentation)
