--[[
    PostLoading (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule → MainMenu
    Parent: MainMenu
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenu")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraModule = require(script.Parent.Parent.Parent.Parent.Handlers.CameraHandler)

local PostLoading = {}

local function FadeOutAudio()
	for i = 0.8, 0, -0.01 do
		game.SoundService.Ambience.Menu.Volume -= i
		task.wait(0.1)
	end
end

function PostLoading.OnLoaded()
	task.spawn(FadeOutAudio)
	task.wait(0.4)
	game.SoundService.Ambience.Menu:Stop()


	MainMenuUI.LoadGameFrame.Visible = false
	MainMenuUI.NewGameFrame.Visible = false
	MainMenuUI.NewGameFrame.NameFrame.Visible = false
	MainMenuUI.NewGameFrame.DifficultyFrame.Visible = false
	
	--PlayerGui.BackpackUI.HotbarFrame.Visible = true
	-- Manage the cameras
	CameraModule.SetCameraType("Custom")
	CameraModule.SetCameraSubject(Player.Character.Humanoid)

	game.SoundService.Ambience.SpaceshipMusic:Play()
	ReplicatedStorage.RemoteEvents.GameInitialized:FireServer()
end

return PostLoading