# World of Warcraft Addons

This directory contains the collection of custom addons developed for **World of Warcraft (WoW) Midnight (12.0+)**.

## Active Projects

### 📌 [WhereIGathered](file:///e:/code-workspaces/WoWAddons/WhereIGathered)
A lightweight, highly optimized addon that automatically records the exact position of your character every time you mine a vein or gather a herb, displaying a permanent icon (ore or plant) on both the minimap and the world map.

*   **Compatibility:** WoW Midnight (Interface version: `120000`)
*   **Key Features:**
    *   **Automatic Recording:** Captures the gathering event and stores 2D coordinates.
    *   **Active Optimization:** Only loads and initializes pins corresponding to the player's current zone (for the minimap) and the currently viewed zone (for the world map).
    *   **Efficient Performance:** Uses the community library `HereBeDragons` and a frame recycling system (*Frame Pooling*) to keep CPU and memory usage minimal and prevent micro-stuttering.
    *   **HUD Navigation & Route Optimization:** Includes a floating, draggable HUD compass and calculates optimal gathering routes using the **Nearest Neighbor** algorithm.
    *   **Chat Control:** `/wig` or `/whereigathered` commands to toggle visibility, manage routes, clean up duplicates, and view statistics.

---

## How to Test and Deploy Addons

To test changes in-game, addons must be copied to the World of Warcraft installation folder.

### Installation Paths
*   **Game Directory:** `D:\Battle.net\World of Warcraft`
*   **Addons Folder (Retail):** `D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns`

### Quick Deployment Script (PowerShell)
You can use this quick PowerShell command to copy an addon directly to your WoW folder after making changes:

```powershell
# Example for WhereIGathered
New-Item -ItemType Directory -Force -Path "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\WhereIGathered"
Copy-Item -Path "E:\code-workspaces\WoWAddons\WhereIGathered\*" -Destination "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\WhereIGathered" -Recurse -Force
```

Once copied, if the game is already running, type `/reload` in the game chat to apply any `.lua` file modifications. If you have added new files (e.g., textures or new `.toc` entries), restart the game or return to the character selection screen.
