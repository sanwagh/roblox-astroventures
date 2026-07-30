--[[
    MissionsClient (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

-- Use module scripts to display and select the missions
local Player:Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false, 0)

local UtilitiesFolder = game.Workspace:WaitForChild("Utilities")
local MissionsDisplay = UtilitiesFolder:WaitForChild("MissionsDisplay")

local MissionsUI = PlayerGui:WaitForChild("MissionsUI")

local MissionsUIModule = require(script.MissionsUI)
local Values = require(script.Parent.Values)

local MoreDetailsBtnConnection = nil

local function BlurFadeIn()
	for i = 0,12,0.2 do
		game.Lighting.Blur.Size = i
		task.wait(0.001)
	end
end

local function BlurFadeOut()
	for i = 12,0,-0.2 do
		game.Lighting.Blur.Size = i
		task.wait(0.001)
	end
end

local function CheckForMissionClick()
	if MoreDetailsBtnConnection then MoreDetailsBtnConnection:Disconnect() end
	
	for i,frame in pairs(MissionsUI.MissionsListFrame.MissionsFrame:GetChildren()) do
		if frame:IsA("Frame") then
		 MoreDetailsBtnConnection =	frame.MoreDetailsBtn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				MissionsUIModule.LoadMissionDescOnClick(frame.MissionName.Text)
			end)
		end
	end
end

local function OnOpen()
	local MissionsFrameTween = TweenService:Create(MissionsUI.MissionsListFrame, Tweeninfo, {Position = UDim2.new(0.138,0,0.5,0)})
	MissionsFrameTween:Play()	
	task.spawn(BlurFadeIn)
	
	MissionsUIModule.LoadMissions()
	
	if Values.MissionsLoaded == true then
		print("Check for click")
		task.spawn(CheckForMissionClick)
	else
		warn("[MissionsClient]: Returned from LoadMissions() but missions were not loaded!")
	end
end

local function OnClose()
	game.SoundService.SFX.SecondaryClick:Play()
	
	local MissionsFrameTween = TweenService:Create(MissionsUI.MissionsListFrame, Tweeninfo, {Position = UDim2.new(-0.5,0,0.5,0)})
	MissionsFrameTween:Play()	
	task.spawn(BlurFadeOut)
end

MissionsDisplay.Display.PromptPart.ProximityPrompt.Triggered:Connect(function(player)
	OnOpen()
end)

MissionsUI.MissionsListFrame.CloseBtn.MouseButton1Down:Connect(OnClose)
