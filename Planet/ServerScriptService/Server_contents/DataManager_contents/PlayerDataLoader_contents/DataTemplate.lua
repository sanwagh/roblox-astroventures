--[[
    DataTemplate (ModuleScript)
    Path: ServerScriptService → Server → DataManager → PlayerDataLoader
    Parent: PlayerDataLoader
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module = {
	LogInTimes = 0;
	LastLoaded = "";
	
	Cash = 0;
	
	Build = {}; --Contains data of all the parts that the player has built
	
	Missions = {	
		ShownMissions = {
			
--==============================================================================================================================
			Planet32BBasic = {
				MissionName = "Planet32BBasic",
				Status = "", --In Progress, Completed, failed
				Type = "Basic",
				--The status will be replicated into the Missions PlayerStatus value to make it simple to read.
				Completed = false,
				Shown = true,
				HiddenMission = false, --If it is an easter egg or a secret mission
				
				
			},
--==============================================================================================================================
			
		},
	},
	
	Backpack = {
		Inventory = {},
		Hotbar = {},
	},
	
	TeleportData = {
		Teleport = false,
		PlanetName = "",
		MissionName = "",
		SpaceshipType = "",
	},
}

return module