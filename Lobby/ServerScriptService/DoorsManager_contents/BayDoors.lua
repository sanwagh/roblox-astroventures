--[[
    BayDoors (ModuleScript)
    Path: ServerScriptService → DoorsManager
    Parent: DoorsManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TweenService = game:GetService("TweenService")
local Tweeninfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.1)

local BayDoorsFolder = game.Workspace:WaitForChild("Doors").BayDoors

local Debounce = false --To Prevent mem leaks

local BayDoorsManager = {}

function BayDoorsManager.Init(Player)
	BayDoorsManager.CheckProximityForEachDoor(Player)
end

local function OpenDoor(Door: Model)
	local Door1 = Door.Door1
	local Door2 = Door.Door2

	local Tween1 = TweenService:Create(Door1.PrimaryPart, Tweeninfo, {CFrame = Door.Door1OpenPosPart.CFrame})
	local Tween2 = TweenService:Create(Door2.PrimaryPart, Tweeninfo, {CFrame = Door.Door2OpenPosPart.CFrame})

	Door.SoundPart.DoorMove:Play()

	Tween1:Play()
	Tween2:Play()
	
	Tween2.Completed:Wait()
	Door.SoundPart.DoorMove:Stop()

end

local function CloseDoor(Door: Model)
	local Door1 = Door.Door1
	local Door2 = Door.Door2

	local Tween1 = TweenService:Create(Door1.PrimaryPart, Tweeninfo, {CFrame = Door.Door1ClosePosPart.CFrame})
	local Tween2 = TweenService:Create(Door2.PrimaryPart, Tweeninfo, {CFrame = Door.Door2ClosePosPart.CFrame})

	Door.SoundPart.DoorMove:Play()

	Tween1:Play()
	Tween2:Play()

	Tween2.Completed:Wait()
	--Door.SoundPart.Close:Play()
	Door.SoundPart.DoorMove:Stop()
end

function BayDoorsManager.CheckProximityForEachDoor(Player)
	while true do
		task.wait(0.2)
		for i,door:Model in pairs(BayDoorsFolder:GetChildren()) do
			if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
			if (Player.Character.HumanoidRootPart.Position - BayDoorsFolder.BayDoorsCheck.Position).Magnitude > 165 then
				break
			end

			if door:IsA("Model") then
				if door:FindFirstChild("DetectorPart") then
					local Distance = (door.DetectorPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude

					if Distance <= 20 then	
						if door.Open.Value == false then 
							door.Open.Value = true
							OpenDoor(door)
						end
					else
						if door.Open.Value == true then 
							door.Open.Value = false
							CloseDoor(door)

						end
					end
				else
					print("[BayDoors]: No detectorpart for: ", door.Name)
				end
			end	
		end
	end
end

return BayDoorsManager