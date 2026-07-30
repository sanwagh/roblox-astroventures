--[[
    TutorialHandler (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--@IMP: This script will be replicated to the refactored version

-- Check if its the players first time, then show the tutorial here. Basic instructions on how to select a mission etc
-- Other imp things will be incorped in the mission script itself in the other sub-place

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tutorial = require(script.Tutorial)

ReplicatedStorage.RemoteEvents.GameInitialized.OnServerEvent:Connect(function(plr)
	print("[Tutorial]: Game has been initialized. All loading completed |", plr)
	
	Tutorial.new(plr):Init()
end)