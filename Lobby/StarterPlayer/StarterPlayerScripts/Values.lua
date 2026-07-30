--[[
    Values (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local module = {}

module.Loaded = false	
module.InventoryOpen = false

module.InventoryUISConnection = nil
module.InventorySlotClickConnection = nil
module.HotbarSlotClickConnection = nil

module.MissionsLoaded = false

return module