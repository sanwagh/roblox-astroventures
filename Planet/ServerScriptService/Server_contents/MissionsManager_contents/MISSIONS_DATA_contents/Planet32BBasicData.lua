--[[
    Planet32BBasicData (ModuleScript)
    Path: ServerScriptService → Server → MissionsManager → MISSIONS_DATA
    Parent: MISSIONS_DATA
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module = {}

module.Planet32BBasicData = {
	MISSION_DISPLAY_NAME = "Planet-32B Basic",
	MISSION_NAME = "Planet32BBasic",
	PLANET_NAME = "Planet32B",
	MISSION_TYPE = "Basic",
	SHIP_NAME = "StarterShip",
	MISSION_INFO = [["Planet32B is a planet that is a replica of earth, or at least it seems to be so. 
	Make sure you dont consme anything on the planet and beware of creatures if any."]],
	
	PlayerStatus = "",
	
	Active = false, 
	Completed = false,
	
	REWARDS = {},
	
}


return module
