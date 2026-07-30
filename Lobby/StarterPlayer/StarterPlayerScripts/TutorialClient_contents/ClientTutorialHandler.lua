--[[
    ClientTutorialHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TutorialClient
    Parent: TutorialClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

-- Main Script that handles the UI and dialogs

local TweenService = game:GetService("TweenService")
local Tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In,0,false,0)

local module = {}
module.__index = module

local Stages = {}

--TODO: When in tutorial mode, hide ALL missions other than the main tutorial one.

function module.new()
	local self = setmetatable({}, module)

	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")

	self.TutorialUI = self.PlayerGui:WaitForChild("TutorialUI")
	self.TutorialFrame = self.TutorialUI.TutorialFrame
	self.ButtonFrame = self.TutorialFrame.ButtonFrame

	--Buttons
	self.NextBtn = self.ButtonFrame.NextBtn


	--Modules
	self.TutorialUIModule = require(script.Parent.TutorialUI).new()
	self.TutorialDialogs = require(script.Parent.TutorialDialogs)

	--EndStage = 12
	self.CurrentStage = 1 -- Stage1 = IntroText
	
	self.TutorialCompleted = false
	
	-- Cameras
	self.Camera = game.Workspace.CurrentCamera
	self.CameraPartsFolder = game.Workspace:WaitForChild("Utilities"):WaitForChild("TutorialCameras")
	
	--misc
	self.TutorialPointerParts = game.Workspace:WaitForChild("Utilities").TutorialPointerParts
	self.RoomDoors = game.Workspace:WaitForChild("Doors").RoomDoors

	self.NEXT_BTN_CONNECTION = nil
	
	-- Tutorial Event Checks
	self.MissionPromptTriggered = false
	self.AcceptBtnClicked = false
	self.LaunchpadDoorOpen = false

	return self
end

function module:Init()	
	self.TutorialUIModule:Init() -- Handles the init of the UI module script (including setting it to visible)
	self.TutorialUIModule:ButtonDetector() -- (Handles the Off screen and on screen UI toggle)
	
	self:StageHandler()
end

function module:StageHandler()
	self:TutorialEvents()
	while not self.TutorialCompleted do
		task.wait(0.1)
		print("[ClientTutorial]: Going to stage "..self.CurrentStage)
		Stages["Stage"..self.CurrentStage](self)
	end
	
	print("[Tutorial]: Completed!")
	self.TutorialUIModule:MoveUIOffScreen()
	self.TutorialFrame.Visible = false
end

function module:WaitForNextClick()
	if self.NEXT_BTN_CONNECTION then self.NEXT_BTN_CONNECTION:Disconnect() end
	local NextClicked = false

	self.NEXT_BTN_CONNECTION = self.NextBtn.MouseButton1Down:Connect(function()
		
		self.CurrentStage += 1
		NextClicked = true
	end)

	while NextClicked == false do
		task.wait()
	end
	
	self.NextBtn.Visible = false
end

local function SetCamToHumanoid(Camera, Player)
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Player.Character.HumanoidRootPart
end

----------------------------------------------------[Stages]---------------------------------------------------------

--Introduction of TITAN
function Stages.Stage1(self)
	if self.CurrentStage ~= 1 then print("Not the correct stage!", self.CurrentStage) return end
	
	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])
	
	self.NextBtn.Visible = true
	
	self:WaitForNextClick()
	return
end

-- Showing of the Missons Display
function Stages.Stage2(self)
	if self.CurrentStage ~= 2 then print("Not the correct stage!", self.CurrentStage) return end
	
	self.Camera.CameraType = Enum.CameraType.Scriptable
	
	local Tween = TweenService:Create(self.Camera, Tweeninfo, {CFrame = self.CameraPartsFolder.MissionsDisplayCamera.CFrame})
	Tween:Play()

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])
	
	SetCamToHumanoid(self.Camera, self.Player)

	self.NextBtn.Visible = true

	self:WaitForNextClick()
	return
end

-- Opening of the display menu
function Stages.Stage3(self)
	if self.CurrentStage ~= 3 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	-- Stage finished will be triggered on proximity prompt trigger
	
	while not self.MissionPromptTriggered do
		task.wait()
	end
	self.CurrentStage += 1
	
	return
end

-- Mission Selection
function Stages.Stage4(self)
	if self.CurrentStage ~= 4 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true

	self:WaitForNextClick()

	return
end


--Mission Accepted
function Stages.Stage5(self)
	if self.CurrentStage ~= 5 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	
	
	while not self.AcceptBtnClicked do
		task.wait()
	end	
	
	self.CurrentStage += 1
	return
end

-- Proceed towards tools
function Stages.Stage6(self)
	if self.CurrentStage ~= 6 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true

	self:WaitForNextClick()

	return
end

-- TITAN gets updated that player will get tools on landing
function Stages.Stage7(self)
	if self.CurrentStage ~= 7 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true

	self:WaitForNextClick()

	return
end

-- Cam Tweens to storage room and the room is highlighted for the player to enter
function Stages.Stage8(self)
	if self.CurrentStage ~= 8 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false
	
	self.Camera.CameraType = Enum.CameraType.Scriptable

	
	local Tween = TweenService:Create(self.Camera, Tweeninfo, {CFrame = self.CameraPartsFolder.StorageRoomCamera.CFrame})
	Tween:Play()

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])
	
	SetCamToHumanoid(self.Camera, self.Player)

	self.NextBtn.Visible = true
	
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = self.Player.Character.HumanoidRootPart
	
	local Beam = Instance.new("Beam")
	Beam.Parent = workspace
	Beam.Attachment0 = Attachment
	Beam.Attachment1 = self.TutorialPointerParts.StorageRoomPointer.Attachment

	self:WaitForNextClick()
	-- MAKE SURE TO REMOVE ALL THE HIGHLIGHTS AFTER THE CLICK (arrows)
	
	Beam:Destroy()
	Attachment:Destroy()
	return
end

-- Player is told to go to Launchpad 3 and waits for the doors to open
function Stages.Stage9(self)
	if self.CurrentStage ~= 9 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])


	local Attachment = Instance.new("Attachment")
	Attachment.Parent = self.Player.Character.HumanoidRootPart

	local Beam = Instance.new("Beam")
	Beam.Parent = workspace
	Beam.Attachment0 = Attachment
	Beam.Attachment1 = self.TutorialPointerParts.Launchpad3Pointer.Attachment
	
	
	
	while not self.LaunchpadDoorOpen do
		task.wait()
	end
	
	Beam:Destroy()
	Attachment:Destroy()
	self.CurrentStage += 1
	return
end

function Stages.Stage10(self)
	if self.CurrentStage ~= 10 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true

	self:WaitForNextClick()

	return
end

function Stages.Stage11(self)
	if self.CurrentStage ~= 11 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true
	
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = self.Player.Character.HumanoidRootPart

	local Beam = Instance.new("Beam")
	Beam.Parent = workspace
	Beam.Attachment0 = Attachment
	Beam.Attachment1 = self.TutorialPointerParts.SwitchPointer.Attachment

	self:WaitForNextClick()
	
	Beam:Destroy()
	Attachment:Destroy()
	return
end

function Stages.Stage12(self)
	if self.CurrentStage ~= 12 then print("Not the correct stage!", self.CurrentStage) return end

	self.NextBtn.Visible = false

	self.TutorialUIModule:TextAnimation(self.TutorialDialogs[self.CurrentStage])

	self.NextBtn.Visible = true

	local Attachment = Instance.new("Attachment")
	Attachment.Parent = self.Player.Character.HumanoidRootPart

	local Beam = Instance.new("Beam")
	Beam.Parent = workspace
	Beam.Attachment0 = Attachment
	Beam.Attachment1 = self.TutorialPointerParts.SpaceshipPointer.Attachment

	self:WaitForNextClick()

	Beam:Destroy()
	Attachment:Destroy()
	
	self.TutorialCompleted = true
	print("[ClientTutorialHandler]: Finished Last Stage!")
	return
end


---------------------------------------------------------Events---------------------------------------------------

function module:TutorialEvents()
	local ProximityPrompt = game.Workspace.Utilities.MissionsDisplay.Display.PromptPart.ProximityPrompt
	ProximityPrompt.Triggered:Connect(function()
		self.MissionPromptTriggered = true
	end)

	--Once the accept btn on the mission Ui is clicked, this proceeds
	self.PlayerGui.MissionsUI.MissionDescriptionFrame.AcceptBtn.MouseButton1Down:Connect(function()
		self.AcceptBtnClicked = true
	end)
	
	self.RoomDoors.Launchpad3Door.RoomDoor.Door1.Door1.Keypad.ProximityPart.OpenPrompt.Triggered:Connect(function()
		self.LaunchpadDoorOpen = true
	end)
end

return module
