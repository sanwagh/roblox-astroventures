--[[
    Animator (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client
    Parent: Client
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

--Calls modules when remote event is fired or an event is triggered
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local Animator = {}
Animator.__index = Animator

function Animator.new()
	local self = setmetatable({}, Animator)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	
	-- INHERITED
	self.TweenService = game:GetService("TweenService")
	
	--Animator Scripts
	self.LandingAnimator = require(script.LandingAnimation)
	
	self.Values = script.Parent.Values
	
	return self
end

function Animator:Init()
	task.spawn(function()
		while self.Values.GameLoadedEventFired.Value == false do task.wait(0.1) end

		self.Values.GameLoadedEventFired.Value = true
		--self.PlayerGui:FindFirstChild("LoadingScreen").PlanetLoadingFrame.Visible = false-- maybe move this to UIhandler
		while self.Values.TerrainLoaded.Value == false do task.wait(0.2) end
		
		self:LoadLandingAnimation()

	end)
end

function Animator:LoadLandingAnimation()
	print("[Animator]: Loading up Landing Animations...")
	local call = self.LandingAnimator.new()
	call:Init()
end

return Animator