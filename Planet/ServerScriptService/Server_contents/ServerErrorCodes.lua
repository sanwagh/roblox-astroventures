--[[
    ServerErrorCodes (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ErrorCodes = {
	--Gameplay Errors
		-- Missions Errors: 10
		-- ShopService Errors: 20
		-- Inventory Errors: 30
		
	["GP3001"] = "Item not located in server.",
	["GP3002"] = "Item not located in Player backpack"
		
}

local module = {}

function module.CompileErrorMsg(Code)
	if not ErrorCodes[Code] then Code = "CRIT-UNKNOWN" end

	return Code.." - "..ErrorCodes[Code]
end


return module
