--[[
    StarterShip (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → Animator → LandingAnimation
    Parent: LandingAnimation
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local TweenService = game:GetService("TweenService")


local CameraShaker = require(script.Parent.Parent.Parent.Handlers.CameraShaker) 

local StarterShip = {}
StarterShip.__index = StarterShip

local Camera = game.Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

function StarterShip.new()
	local self = setmetatable({}, StarterShip) 
		
	self.AnimationPath = nil
	self.Spaceship = game.Workspace:WaitForChild("StarterShip")

	self.Player = game.Players.LocalPlayer
	
	self.Sounds = self.Spaceship.Thruster.Sounds
	return self
end

function StarterShip:Init()
	self:StartAnimation()
end



local function SetCamera(Part)
	Camera.CFrame = Part.CFrame
end

function StarterShip:StartAnimation() --TODO_HIGH: Remove sequence one
	self:EnableThrusters()
	self:FirstSequence()
	self:SecondSequence()
end

function StarterShip:EnableThrusters()
	self.Spaceship.Thruster.Fire.Enabled = true
	self.Sounds.Engine:Play()
end

function StarterShip:FirstSequence()
	self.AnimationPath = game.Workspace:WaitForChild("Models").AnimationPath
	
	--Set cam to the ground. (Create a part as a cam)
	Camera.CameraType = Enum.CameraType.Scriptable

	--Camera facing the ship on the ground.
	--As the ship lands, cam moves with the ship
	
	local ModelsFolder = game.Workspace:FindFirstChild("Models")
	local LandingCam = ModelsFolder:FindFirstChild("LandingCam")
	if not LandingCam then warn("[Animator]: Could not find the Landing Camera!") return end

	SetCamera(LandingCam)
	print("SetCam to LandingCam")
	task.wait(0.3)

	local Tweeninfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0.2)
	local Tween = TweenService:Create(self.Spaceship.PrimaryPart, Tweeninfo, {CFrame = self.AnimationPath.Sequence1.CFrame})


	Tween:Play()
	task.wait(1.5)

	print("Tweening Cam + Ship")
	--SetCamera(LandingCam)
	local Tweeninfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0.2)

	local Tween = TweenService:Create(self.Spaceship.PrimaryPart, Tweeninfo, {CFrame = self.AnimationPath.Parent.LandingPos.CFrame})
	local CamTween = TweenService:Create(Camera, Tweeninfo, {CFrame = LandingCam.CFrame * CFrame.Angles(43,0,0)})


	--local CamShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(Shake)
	--	Camera.CFrame = Camera.CFrame * Shake
	--end)
	
	print("shake")
	
	--CamShake:Start()
	--CamShake:ShakeOnce(5,8,1)
	Tween:Play()
	CamTween:Play()

	ModelsFolder.LandingPos.Smoke.Enabled = true
	
	task.spawn(function()
		for i = self.Sounds.Engine.Volume, 0,-0.05 do
			self.Sounds.Engine.Volume = i
			task.wait(0.1)
		end
	end)


	Tween.Completed:Wait()
	self.Sounds.Shutdown:Play()
	--CamShake:ShakeOnce(5,8,1)
	self.Sounds.Engine:Stop()
	

	ModelsFolder.LandingPos.Smoke.Enabled = false
	self.Spaceship.Thruster.Fire.Enabled = false
	self.Spaceship.Thruster.Smoke.Enabled = false
	
	task.wait(1)
	--CamShake:Stop()	
end

function StarterShip:SecondSequence()
	--Move the Camera towards the ship
	local Tweeninfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0.2)
	local Tween = TweenService:Create(Camera, Tweeninfo, {CFrame = self.Spaceship.PrimaryPart.CFrame})

	Tween:Play()	
	task.wait(1.7)
	self:FadeOutScene()

end


function StarterShip:FadeOutScene()
	print("Fade")
	self.Player.PlayerGui.LoadingUI.BlackFrame.Visible = true
	
	for i = 1,0,-0.1 do
		self.Player.PlayerGui.LoadingUI.BlackFrame.BackgroundTransparency = i
		task.wait(0.01)
	end
	
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = self.Player.Character.Humanoid
	self.Player.Character.HumanoidRootPart.CFrame = CFrame.new(self.Spaceship.PlayerSpawnPart.Position)
	
	self.Spaceship.TopDoorClose.Transparency = 1
	self.Spaceship.TopDoorOpen.Transparency = 0
	self.Spaceship.Ladder.Transparency = 0
	self.Spaceship.Ladder.CanCollide = true

	task.wait(1.2)
	
	for i = 0,1,0.1 do
		self.Player.PlayerGui.LoadingUI.BlackFrame.BackgroundTransparency = i
		task.wait(0.01)
	end
	self.Player.PlayerGui.LoadingUI.BlackFrame.Visible = false

	print("[Animator]: Completed Animations!")
	game.ReplicatedStorage.RemoteEvents.FinishedAnimation:FireServer("Landing")
end

return StarterShip