--[[
    StartershipLaunchAnimation (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Animations
    Parent: Animations
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--Module (child) manages the launch animation
-- Doors close which is called by firing a remote function (wait for return) and the server handles closing the doors

--[[
	CONNECTIONS FOR STARTUP
	- Spaceship to launch control
	- Launch Mode
	- Activate Preliminary startup
	- Start Ship electricals
	- Prepare Launch
	-----Player goes into the ship 
	- Start Engine
	- Auto boost (player does not need to do anything)
]]

--ADD MORE METHODS HERE LATER TO INIT EVERYTHING FOR THE LAUNCH

local Player = game.Players.LocalPlayer
local Launchpad3 = game.Workspace:WaitForChild("LaunchPads").LaunchPad3

local Startership = game.Workspace:WaitForChild("Utilities").Spaceships.StarterShip

local StartersshipAnimator = require(script.StarterShipAnimator)

local Checklist = { --["key"] = boolean
	["ShipToLaunchControlConnection"] = false,
	["LaunchMode"] = false,
	["PreliminaryStartup"] = false,
	["PowerUpStation"] = false, --Requirement: ALl the above should be true
	["ShipElectrics"] = false,
	["PrepareLaunch"] = false,
	["StartEngine"] = false
}

local function SetChecklistValueTrue(Value)
	if Checklist[Value] == true then print("Already True!") return end
	print("Set true:", Value)
	Checklist[Value] = true
end

local function ReadyToLaunch()
	for i,v in pairs(Checklist) do
		if i == "StartEngine" then continue end
		if v == false then
			print(i," is not enabled! (display on screen)")
			return false
		end
	end
	return true
end

local function CheckForActiveMission()
	if Player.MissionName.Value ~= "" then 
		return true
	else
		return false
	end
end

local function InitiateLaunchAnimation()
	StartersshipAnimator.Init()
end

Startership.LaunchButton.ProximityPrompt.Triggered:Connect(function()
	if ReadyToLaunch() then
		if not CheckForActiveMission() then 
			warn("[LaunchAnim]: Player did not select a mission") 
		
			Player.PlayerGui.Info.InfoLabel.Visible = true
			Player.PlayerGui.Info.InfoLabel.Text = "Please Select a Mission to Proceed"
			task.wait(1)
			Player.PlayerGui.Info.InfoLabel.Visible = false

			return
		end
		
		--TODO: Check for spacehip type
		Startership.LaunchButton.ProximityPrompt.Enabled = false
		InitiateLaunchAnimation()	
	end
end)

for i,v in pairs(Launchpad3.Launchpad3.LaunchButtons:GetChildren()) do
	if v:FindFirstChild("ProximityPrompt") then
		
		v.ProximityPrompt.Triggered:Connect(function()
			v.Color = Color3.new(0.72549, 0.72549, 0.72549)
			v.ProximityPrompt.Enabled = false
			SetChecklistValueTrue(v.Name)
		end)
	end
end