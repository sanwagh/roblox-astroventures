--[[
    DataTemplate (ModuleScript)
    Path: ServerScriptService → PlayerData → DataService → PlayerDataLoader
    Parent: PlayerDataLoader
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local module = {
	LogInTimes = 0;
	LastLoaded = "";
	
	Cash = 0;
	Exp = 0; -- Exp will be converted to levels in real time
	
	Build = {}; --Contains data of all the parts that the player has built
	
	Missions = {	
		ShownMissions = {
			
--==============================================================================================================================
			Planet32BBasic = {
				MissionName = "Planet32BBasic",
				Status = "", --In Progress, Completed, failed
				--The status will be replicated into the Missions PlayerStatus value to make it simple to read.
				Completed = false, -- Will be set to true even if the mission is failed
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
	
	PlayerTeleportData = {
		Teleport = false,
		PlanetName = "",
		MissionName = "",
		SpaceshipType = "",
	},
}

return module