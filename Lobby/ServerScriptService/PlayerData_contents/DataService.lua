--[[
    DataService (ModuleScript)
    Path: ServerScriptService → PlayerData
    Parent: PlayerData
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local SlotLoader = require(script.SlotLoader)
local PlayerDataLoader = require(script.PlayerDataLoader)

local DataService = {}

-- Manages all the data including slot loading and main data loading
function DataService.OnInit()
	-- Slot Loader first
	game.Players.PlayerAdded:Connect(function(player)
		SlotLoader.Initialize(player)
	end)
end

return DataService