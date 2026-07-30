--[[
    RoomDoors (ModuleScript)
    Path: ServerScriptService → DoorsManager
    Parent: DoorsManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TweenService = game:GetService("TweenService")
local Tweeninfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

local DoorFolder = game.Workspace:WaitForChild("Doors").RoomDoors

local RoomDoors = {}


function RoomDoors.OpenDoor(Player,Door)
	if Player.MissionName.Value == "" and Door:GetAttribute("LaunchpadDoor") then

		Player.PlayerGui.Info.InfoLabel.Visible = true
		Player.PlayerGui.Info.InfoLabel.Text = "Please Select a Mission to Proceed"
		task.wait(1)
		Player.PlayerGui.Info.InfoLabel.Visible = false

		return 
	end
	print("Open")
	local Door1 = Door.RoomDoor.Door1
	local Door2 = Door.RoomDoor.Door2
	
	local Door1OpenPos = Door.RoomDoor.Door1OpenPosPart.CFrame
	local Door2OpenPos = Door.RoomDoor.Door2OpenPosPart.CFrame
	
	local SoundPart = Door2:FindFirstChild("SoundPart")
	
	if not SoundPart then warn("Sound Part is not detected!", Door) return end
	
	Door1.PrimaryPart.Keypad.ProximityPart.OpenPrompt.Enabled = false
	SoundPart.Open:Play()

	local Tween = TweenService:Create(Door1.PrimaryPart, Tweeninfo, {CFrame = (Door1OpenPos)})
	Tween:Play()
	SoundPart.DoorWhir:Play()

	Tween.Completed:Wait()

	task.wait(0.2)

	local Tween = TweenService:Create(Door2.PrimaryPart, Tweeninfo, {CFrame = (Door2OpenPos)})

	Tween:Play()

	Tween.Completed:Wait()

	SoundPart.Close:Play()

	Door1.PrimaryPart.Keypad.ProximityPart.ClosePrompt.Enabled = true	
	
end

function RoomDoors.CloseDoor(Player,Door)
	print("Close")
	local Door1 = Door.RoomDoor.Door1
	local Door2 = Door.RoomDoor.Door2
	local SoundPart = Door2:FindFirstChild("SoundPart")
	
	local Door1ClosePos = Door.RoomDoor.Door1ClosePosPart.CFrame
	local Door2ClosePos = Door.RoomDoor.Door2ClosePosPart.CFrame
	
	Door1.PrimaryPart.Keypad.ProximityPart.ClosePrompt.Enabled = false

	local Tween = TweenService:Create(Door2.PrimaryPart, Tweeninfo, {CFrame = (Door2ClosePos)})


	Tween:Play()

	SoundPart.DoorWhir:Play()
	Tween.Completed:Wait()

	task.wait(0.2)

	local Tween = TweenService:Create(Door1.PrimaryPart, Tweeninfo, {CFrame = (Door1ClosePos)})

	Tween:Play()

	Tween.Completed:Wait(0.1)
	SoundPart.Close:Play()

	task.wait(0.3)
	SoundPart.Open:Play()


	Door1.PrimaryPart.Keypad.ProximityPart.OpenPrompt.Enabled = true	
end

return RoomDoors
