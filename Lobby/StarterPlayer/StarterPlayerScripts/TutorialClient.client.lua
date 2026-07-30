--[[
    TutorialClient (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local ClientTutorialHandler = require(script.ClientTutorialHandler)
local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local TutorialEvent = RemoteEvents.TutorialEvent

TutorialEvent.OnClientEvent:Connect(function(EventType)	
	if EventType == "Start" then
		print("[Tutorial]: Starting Tutorial")
		task.wait(1)
		ClientTutorialHandler.new():Init()
	end
end)
