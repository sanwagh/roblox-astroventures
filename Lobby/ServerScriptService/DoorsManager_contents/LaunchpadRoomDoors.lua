--[[
    LaunchpadRoomDoors (ModuleScript)
    Path: ServerScriptService → DoorsManager
    Parent: DoorsManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.9,Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0.2)

local LaunchRoomDoors = game.Workspace:WaitForChild("Doors").LaunchpadRoomDoors
local Debounce = false

local LaunchRoomDoorManager = {}

function LaunchRoomDoorManager.OpenDoor(Player, Door)
	if Player.MissionName.Value == "" then
		
		Player.PlayerGui.Info.InfoLabel.Visible = true
		Player.PlayerGui.Info.InfoLabel.Text = "Please Select a Mission to Proceed"
		task.wait(1)
		Player.PlayerGui.Info.InfoLabel.Visible = false
		
		return 
	end
	
	print("Open")
	local RoomDoor = Door.RoomDoor
	local DoorOpenPos = Door.DoorOpenPos
	
	local SoundPart = RoomDoor.SoundPart
	
	RoomDoor.ProximityPart.OpenPrompt.Enabled = false
	SoundPart.Lock:Play()
	
	local Tween = TweenService:Create(RoomDoor.PrimaryPart, Tweeninfo, {CFrame = DoorOpenPos.CFrame})
	Tween:Play()
	print("Playing tween")
	--SoundPart.DoorWhir:Play()
	
	Tween.Completed:Wait()
	RoomDoor.ProximityPart.ClosePrompt.Enabled = true
end

function LaunchRoomDoorManager.CloseDoor(Player,Door)
	local RoomDoor = Door.RoomDoor
	local DoorClosePos = Door.DoorClosePos

	local SoundPart = RoomDoor.SoundPart

	RoomDoor.ProximityPart.ClosePrompt.Enabled = false

	local Tween = TweenService:Create(RoomDoor.PrimaryPart, Tweeninfo, {CFrame = DoorClosePos.CFrame})
	Tween:Play()
	SoundPart.DoorWhir:Play()

	Tween.Completed:Wait()
	SoundPart.Close:Play()
	task.wait(0.2)
	--SoundPart.DoorWhir:Stop()
	SoundPart.Lock:Play()
	
	RoomDoor.ProximityPart.OpenPrompt.Enabled = true
end


return LaunchRoomDoorManager