--[[
    Basic (ModuleScript)
    Path: ServerScriptService → Server → MissionsManager → Planet32BBasic
    Parent: Planet32BBasic
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local Basic = {}
Basic.__index = Basic

function Basic.new()
	local self = setmetatable({}, Basic)
	
	return self
end

function Basic:Init()
	-- The missions_Data module has the objectives and everything. So this script controls the increment and completikon of those
	
end

return Basic