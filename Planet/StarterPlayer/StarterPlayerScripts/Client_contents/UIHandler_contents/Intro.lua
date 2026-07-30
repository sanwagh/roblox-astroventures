--[[
    Intro (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler
    Parent: UIHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local Intro = {}
Intro.__index = Intro

function Intro.new()
	local self = setmetatable({}, Intro)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.LoadingUI = self.PlayerGui:WaitForChild("LoadingUI")
	
	self.TeleportFrame = nil
	
	self.Values = (script.Parent.Parent:WaitForChild("Values"))
	
	return self
end

function Intro:Init()
	task.spawn(function()
		self:HideLoadingScreen()
	end)
end

function Intro:HideLoadingScreen()
	self.TeleportFrame = self.PlayerGui:WaitForChild("TeleportUI").PlanetLoadingFrame
	
	if not self.TeleportFrame then warn("[Intro]: TeleportUI was not located") return end
	
	while self.Values.GameLoadedEventFired.Value == false do task.wait(0.1) end
	while self.Values.TerrainLoaded.Value == false do task.wait(0.1) end
	
	self.TeleportFrame.Visible = false
	print("[Intro]: Set TeleportFrame to invisible")
	game.SoundService:WaitForChild("Ambience").Teleportation:Stop()()

end

return Intro