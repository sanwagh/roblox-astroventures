--[[
    LandingAnimation (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → Animator
    Parent: Animator
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local LandingAnimation = {}
LandingAnimation.__index = LandingAnimation

local Camera = game.Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

function LandingAnimation.new()
	local self = setmetatable({}, LandingAnimation)
	
	self.TweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0.2)
	self.Spaceship = nil
	
	self.Player = game.Players.LocalPlayer
	
	return self
end

function LandingAnimation:Init()
	
	--Recognise the type and redirect for animation
	if self.Player.SpaceshipName.Value == "StarterShip" then
		local import = require(script.StarterShip)
		import.new():Init()
	else
		warn("[Animator]: Invalid Spaceship!,", self.Player.SpaceshipName.Value)
	end
	self.Player.PlayerGui.BackpackUI.HotbarFrame.Visible = true
end





return LandingAnimation