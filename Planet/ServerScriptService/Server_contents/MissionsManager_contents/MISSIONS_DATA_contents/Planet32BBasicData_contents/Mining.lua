--[[
    Mining (ModuleScript)
    Path: ServerScriptService → Server → MissionsManager → MISSIONS_DATA → Planet32BBasicData
    Parent: Planet32BBasicData
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module1 = {}

module1.Completed = false

module1.Stone = {
	Completed = false,
	
	CurrentAmount = 0,
	TotalAmount = 20,
	
}

module1.Desc = "Look for a cave and mine a few stone or any ore that you spot. Keep in mind not all ores are safe!"

return module1
