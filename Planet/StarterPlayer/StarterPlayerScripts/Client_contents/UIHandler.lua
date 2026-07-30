--[[
    UIHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client
    Parent: Client
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local Player = game.Players.LocalPlayer

local UIHandler = {}
UIHandler.__index = UIHandler

function UIHandler.new()
	local self = setmetatable({}, UIHandler)
	
	return self
end

function UIHandler:Init()
	for i, module in pairs(script:GetChildren()) do
		if module:HasTag("Exempt") then continue end
		
		if module:IsA("ModuleScript") then
			task.spawn(function()
				local success, err = pcall(function()
					print("[UIHandler]: Loading UI module", tostring(module.Name))
					local import = require(module)
					import.new():Init()
				end)
				if not success then warn("[ERROR]:", err) end
			end)
		end
	end
end


print("[UIHandler]: Loaded all UI modules.")



return UIHandler