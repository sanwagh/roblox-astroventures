--[[
    StarterShipAnimator (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Animations → StartershipLaunchAnimation
    Parent: StartershipLaunchAnimation
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--------------------------------------------------[VARIABLES]-----------------------------------------------------------
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")

local SpaceshipsFolder = game.Workspace:WaitForChild("Utilities").Spaceships
local StarterShip = SpaceshipsFolder:FindFirstChild("StarterShip")
local FloorLights = game.Workspace:WaitForChild("Decoration").FloorLightStrips.Floor2Lights.Launchpad3Lights
local Launchpad3Cam = game.Workspace.Decoration.Cameras.Launchpad3Cam
local Launchpad3 = game.Workspace:WaitForChild("LaunchPads").LaunchPad3
local SmokePart = game.Workspace.LaunchPads.LaunchPad3.Launchpad3.SmokePart

local TeleportUI = PlayerGui:WaitForChild("TeleportUI")

local Camera = game.Workspace.CurrentCamera

local CameraShakerModule = require(Player.PlayerScripts.CameraShaker)
local PlanetLoadingScreenModule = require(script.Parent.Parent.PlanetLoadingScreen)

local TWEENINFO_VAL = 2
local Tweeninfo = TweenInfo.new(TWEENINFO_VAL, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false,0.2)

local PlanetLoaded = false

local Animation = {}

--TODO:UPDATE - Add health and fuel check before starting the animation.

local CamShake = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(Shake)
	Camera.CFrame = Launchpad3Cam.CFrame * Shake
end)

--------------------------------------------------[CONSTRUCTOR]-----------------------------------------------------------


function Animation.Init()
	--[[
			- Camera pos change!

		- Turn the light strips red while playing the alarm !
		= Close the main launchpad door followed by the launch control doors!
		- Wait for a second!
		- Start Engine sound!
		- Ship doors close!
		--Set Status screen status to launching
		- Liftoff sound
		- fade out
		- fade in (near planet for touchdown)
		- Cam attached to the ship
		-- slow down ship
		-- enable Thruster
		-- land
		- Player walks out
		- camera changes to the player
	]]

	Animation.SetCamera()
	task.wait(0.5)
	Animation.ChangeLightColorToRed()
	task.wait(1.2)
	Animation.CloseDoors()
	Animation.OpenLaunchDoors()
	Animation.StartEngine()
	Animation.LiftOff()
	task.wait(0.3)
	Animation.PostLaunch()
end


---------------------------------------------------[TAKEOFF ANIM]--------------------------------------------------------

function Animation.SetCamera()
	StarterShip.Ladder.Transparency = 1
	Player.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0,5,0))

 	Launchpad3.StatusBoard.Display.SurfaceGui.StatusDisplay.TextColor = BrickColor.new(1, 0.333333, 0)
	Launchpad3.StatusBoard.Display.SurfaceGui.StatusDisplay.Text = "Preparing Launch"

	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = Launchpad3Cam.CFrame

	print("[StartershipAnimation]: Set cam")
	PlayerGui.BackpackUI.HotbarFrame.Visible = false
	warn("Set Backpack to false!")
	
	StarterShip.DoorClosed.Transparency = 0
	StarterShip.Door.Transparency = 1
end

function Animation.ChangeLightColorToRed() --DEF_COL 171, 255, 252
	for _, light in pairs(FloorLights:GetDescendants()) do
		if light:IsA("SurfaceLight") then
			light.Color = Color3.new(1, 0, 0.0156863)
		end
	end
	game.Workspace.SoundRegions.LaunchpadWhir.Alert:Play()
end

function ReverLightColor()
	for _, light in pairs(FloorLights:GetDescendants()) do
		if light:IsA("SurfaceLight") then
			light.Color = Color3.fromRGB(171, 255, 252)
		end
	end
end

function Animation.CloseDoors()
	ReplicatedStorage.RemoteEvents.DoorEvent:FireServer("Close", "Launchpad3Door")
	task.wait(0.8)
	ReplicatedStorage.RemoteEvents.DoorEvent:FireServer("Close", "LaunchControl3Door1")
	ReplicatedStorage.RemoteEvents.DoorEvent:FireServer("Close", "LaunchControl3Door2")
	
	
	local DoorClosed = StarterShip.DoorClosed
	local Door = StarterShip.Door
	
	local Tween = TweenService:Create(Door, Tweeninfo, {CFrame = DoorClosed.CFrame}) --Not working

	print(Tween)
	Tween:Play()
	Tween.Completed:Wait()
end



function Animation.StartEngine()
	--sounds, beams and particles 
	StarterShip.Thruster.Sounds.Startup:Play()


	--TODO CLOSE DOORS

	task.wait(0.5)

	StarterShip.Thruster.Fire.Enabled = true
	StarterShip.Thruster.Smoke.Enabled = true

	print("Close doors")
	StarterShip.Thruster.Sounds.Close:Play()

	while StarterShip.Thruster.Sounds.Close.IsPlaying do
		task.wait()
	end

	task.wait(1)



	CamShake:Start()

	CamShake:ShakeOnce(5,8,1)

	print("Add camera shake")
	StarterShip.Thruster.Sounds.Liftoff:Play()
	SmokePart.Smoke.Lifetime = NumberRange.new(0.1)
	task.wait(0.2)

end

function Animation.OpenLaunchDoors()
	local Tweeninfo = TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false,0.2)

	local LaunchDoor = Launchpad3.Utilities.LaunchDoor
	local SoundPart = LaunchDoor.SoundPart
	
	local Tween1 = TweenService:Create(LaunchDoor.LaunchDoor1, Tweeninfo, {Position = LaunchDoor.LaunchDoor1OpenPos.Position})
	local Tween2 = TweenService:Create(LaunchDoor.LaunchDoor2, Tweeninfo, {Position = LaunchDoor.LaunchDoor2OpenPos.Position})
	
	SoundPart.SteamRelease:Play()
	task.wait(0.1)
	SoundPart.SteamReleaseLong:Play()
	task.wait(0.18)
	SoundPart.Whir1:Play()
	SoundPart.Whir2:Play()
	Tween1:Play()
	Tween2:Play()
	
	Tween2.Completed:Wait()
	SoundPart.Whir1:Stop()
	SoundPart.Whir2:Stop()
	SoundPart.SteamRelease:Play()
end

function Animation.LiftOff()
	--using tween service

	SmokePart.Smoke.Enabled = true

	--local Tween1 = TweenService:Create(StarterShip.PrimaryPart, Tweeninfo, {CFrame = StarterShip.CFrame + CFrame.new(0,5,0)})

	--Tween1:Play()

	--Tween1.Completed:Wait()

	local Tween1 = TweenService:Create(StarterShip.PrimaryPart, Tweeninfo, {CFrame = CFrame.new(StarterShip.PrimaryPart.Position + Vector3.new(0,200,0))})

		
	CamShake:ShakeOnce(2,8,1)
	SmokePart.Smoke.Lifetime = NumberRange.new(0.7)

	Tween1:Play()
	print("Playing Tween")


	Tween1.Completed:Wait()
	
	
	CamShake:Stop() --end of function
	SmokePart.Smoke.Enabled = false

	StarterShip.Thruster.Fire.Enabled = false
	StarterShip.Thruster.Smoke.Enabled = false
	task.wait(1)
	--Fade out
	StarterShip.Thruster.Sounds.Liftoff:Stop()
	
	StarterShip:Destroy()
end



function Animation.PostLaunch()
	PlanetLoadingScreenModule.ShowScreen()
	ReplicatedStorage.RemoteEvents.PlanetTeleport:FireServer(StarterShip)
end

return Animation