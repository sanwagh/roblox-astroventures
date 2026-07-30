--[[
    Animations (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → [OLD]TabletClient
    Parent: [OLD]TabletClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--Include:
-- Animation when the tab is accessed
-- Button animation on login (small to original size)

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local TabletUI = PlayerGui:WaitForChild("TabletUI")

local Camera = game.Workspace.CurrentCamera

local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false, 0.1)

local Animations = {}

function Animations.TabletOpenAnimation()
	Camera.CameraType = Enum.CameraType.Scriptable
	
	local TabClone = game.ReplicatedStorage.Tablet:Clone()
	TabClone.Parent = Player.Character
	local HumanoidRootPart = Player.Character.HumanoidRootPart
	
	local Orientation = HumanoidRootPart.Orientation
	local Radians = math.rad
	
	local FinalPos = CFrame.new(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector*0.75) * CFrame.Angles(Radians(Orientation.X),Radians(Orientation.Y),Radians(Orientation.X))
	
	TabClone:PivotTo(FinalPos)
	
	local Tween = TweenService:Create(Camera, Tweeninfo, {CFrame = (TabClone.CameraPart.CFrame)})
	Tween:Play()

	task.wait(0.4)

end

local function IsFirstPerson(): boolean
	return (Camera.CFrame.Position - Camera.Focus.Position).Magnitude <= 0.75
end

function Animations.TabletCloseAnimation()
	Player.Character:FindFirstChild("Tablet"):Destroy()	
	local FinalPos
	
	local Head = Player.Character.Head
	local HeadOrientation = Head.Orientation
	local Rad = math.rad
	
	if IsFirstPerson() then
		--If the player is in first person
		FinalPos = Head.CFrame
	else
		FinalPos = Head.CFrame * CFrame.Angles(Rad(HeadOrientation.X),Rad(HeadOrientation.Y),Rad(HeadOrientation.Z))
	end
	
	local Tween = TweenService:Create(Camera, Tweeninfo, {CFrame = FinalPos})
	Tween:Play()
	Tween.Completed:Wait()
	
	Camera.CameraType = Enum.CameraType.Custom
end

function Animations.ButtonsAnimationOnLoad()
	
end

return Animations