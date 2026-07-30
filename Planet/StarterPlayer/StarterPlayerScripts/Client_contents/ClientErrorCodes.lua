--[[
    ClientErrorCodes (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client
    Parent: Client
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ErrorCodes = {
	-- Gameplay Errors
		-- 10: 
		-- 20: InventoryErrors 
	
	["GP2001"] = "Hotbar Item limit exceeded.",
	["GP2002"] = "Inventory Limit Exceeded",
	["GP2003INV"] = "Item in inventory slot not found in player backpack.",
	["GP2003HB"] = "Item in hotbar slot not found in player backpack.",
	["GP2004"] = "Item Duplication detected in player backpack",
	--UI Errors:

	
	
	["CRIT-UNKNOWN"] = "Please contact the developer regarding this issue.",
}
local module = {}

function module.CompileErrorMsg(Code)
	if not ErrorCodes[Code] then Code = "CRIT-UNKNOWN" end
	
	return Code.." - "..ErrorCodes[Code]
end


return module
