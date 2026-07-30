--[[
    Client (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

--TODO:HIGH- Init the anim for now without dataloading with default data
local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local Values = script.Values

task.spawn(function()
	for i,modules in ipairs(script:GetChildren()) do
		if modules:IsA("ModuleScript") and modules:GetAttribute("Priority") and not modules:GetAttribute("Exempt") then
			local import = require(modules)
			print("[CLIENT]: Loading PRIORITY module:", tostring(modules.Name))
			local Call = import.new()

			Call:Init()
		end
	end

	print("[CLIENT]: Loaded Priority Modules!")

	for i,modules in ipairs(script:GetChildren()) do
		if modules:IsA("ModuleScript") and not modules:GetAttribute("Priority") and not modules:GetAttribute("Exempt") then
			local import = require(modules)
			print("[CLIENT}: Loading  module:", tostring(modules.Name))
			local Call = import.new()

			Call:Init()
		end
	end
end)

RemoteEvents:WaitForChild("GameLoaded").OnClientEvent:Connect(function()
	print("[CLIENT]: Game Loaded!")
	Values.GameLoadedEventFired.Value = true
	print(Values)
end)
