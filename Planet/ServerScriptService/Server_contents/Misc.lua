--[[
    Misc (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

--Manages misc functions like teleporting the spaceship etc. Calls the child module when an event is triggered
local Misc = {}
Misc.__index = Misc

function Misc.new()
	local self = setmetatable({}, Misc)
	
	return self
end


function Misc:Init()

end


return Misc