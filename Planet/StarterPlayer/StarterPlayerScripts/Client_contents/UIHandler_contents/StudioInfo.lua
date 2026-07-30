--[[
    StudioInfo (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler
    Parent: UIHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local StudioInfo = {}
StudioInfo.__index = StudioInfo

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

function StudioInfo.new()
	local self = setmetatable({}, StudioInfo)

	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.StudioInfo = self.PlayerGui:WaitForChild("StudioInfo")

	self.Values = (script.Parent.Parent:WaitForChild("Values"))

	return self
end

function StudioInfo:Init()
	if RunService:IsStudio() then self:ShowStagingLoadingScreen() end

	task.spawn(function()
		self:WaitForGameLoad()
	end)

	self:HideUI()	
end

function StudioInfo:HideUI()
	for i,ui in pairs(self.StudioInfo:GetChildren()) do
		if ui:HasTag("HideInClientRT") then
			ui.Visible = false
		end
	end
	print("[StudioInfo]: Hidden all Studio UI elements")
end

function StudioInfo:ShowStagingLoadingScreen()
	game.SoundService:WaitForChild("Ambience").Teleportation:Play()

	print("[StudioInfo]: Showing StagingLoadingFrame")
	self.StudioInfo.LoadingFrame.Visible = true
end

function StudioInfo:WaitForGameLoad()
	while self.Values.GameLoadedEventFired.Value == false do task.wait(0.1) end
	while self.Values.TerrainLoaded.Value == false do task.wait(0.1) end

	self.StudioInfo.LoadingFrame.Visible = false
	print("[StudioInfo]: Set StagingLoadingFrame to false!")
	game.SoundService:WaitForChild("Ambience").Teleportation:Stop()

end

return StudioInfo
