--[[
    UIControllerModule (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController
    Parent: IntroController
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer


local UIController = {}

function UIController.OnInit()
	for i, module in pairs(script:GetChildren()) do
		if module:IsA("ModuleScript") then
			local import = require(module)
			if import.OnInit then
				task.spawn(import.OnInit)
			end
		end
	end
end

return UIController