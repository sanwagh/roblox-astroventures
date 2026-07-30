--[[
    ServerErrorCodes (ModuleScript)
    Path: ServerScriptService → ErrorCodes
    Parent: ErrorCodes
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local ErrorCodes = {
	
	--Gameplay Errors
		-- Missions Errors: 100
		-- ShopService Errors: 200
		
	["GP10001"] = "Missions Folder not found",
	["GP20001"] = "Could not get Items folder",
	["GP20101"] = "Could not fetch ",
	
	
	--DataStore Errors
		-- Generic Errors: 100
		-- Load Errors: 200
		-- Save Errors: 300
		-- ProfileService Errors: 400
		-- ProfileService Load and Update: 500
		-- SlotLoader Errors: 600
		-- TeleportData Errors: 700
		
	["DS10001"] = ""
}


return ErrorCodes