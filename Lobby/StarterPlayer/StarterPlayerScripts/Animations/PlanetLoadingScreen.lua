--[[
    PlanetLoadingScreen (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Animations
    Parent: Animations
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")

local TeleportUI = PlayerGui:WaitForChild("TeleportUI")
local TipsModule = require(Player:WaitForChild("PlayerScripts").IntroController.UIControllerModule.Intro.Tips)

local PlanetLoaded = false


local PlanetLoadingScreen = {}

local function AnimateLoadIcon()
	while PlanetLoaded == false do
		task.wait(0.01)
		TeleportUI.PlanetLoadingFrame.LoadingIcon.Rotation += 10
	end
end

local function GetTip()
	--Load the module with tips and choose one
	local RandNum = math.random(1, #TipsModule)
	return TipsModule[RandNum]
end

local function GetCurrentPlanetName()
	return Player.PlanetName.Value
end

local function ShowLoadingScreen()
	local PlanetName = GetCurrentPlanetName()
	local PlanetImage = ReplicatedStorage.PlanetData.PlanetLoadingImages:FindFirstChild(PlanetName).Value

	print(TeleportUI, TeleportUI:FindFirstChild("PlanetLoadingFrame"), TeleportUI:GetChildren())
	TeleportUI.PlanetLoadingFrame.BackgroundImage.Image = tostring(PlanetImage)
	TeleportUI.PlanetLoadingFrame.TextFrame.PlanetName.Text = PlanetName
	TeleportUI.PlanetLoadingFrame.Visible = true --Value Changed after the camera is set

	TeleportUI.PlanetLoadingFrame.TextFrame.TipFrame.Tip.Text = GetTip()

	task.spawn(AnimateLoadIcon)
	PlanetLoaded = false
end

function PlanetLoadingScreen.ShowScreen()
	game.SoundService.Ambience.SpaceshipMusic:Stop()
	game.SoundService.Ambience.Teleportation:Play()
	game.Workspace.SoundRegions.LaunchpadWhir.Whir:Stop()
	ShowLoadingScreen()
	TeleportUI.PlanetLoadingFrame.LoadingIcon.Visible = false
	TeleportUI.PlanetLoadingFrame.TextFrame.Loading.Text = "Requesting Server..."
end


return PlanetLoadingScreen