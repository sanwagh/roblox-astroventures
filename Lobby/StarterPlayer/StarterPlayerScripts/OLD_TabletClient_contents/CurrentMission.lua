--[[
    CurrentMission (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → [OLD]TabletClient
    Parent: [OLD]TabletClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local TabletUI = PlayerGui:WaitForChild("TabletUI")
local CurrentMissionFrame = TabletUI.TabletFrame.ScreenFrame.MissionFrame

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")

local PinTaskModule = require(script.PinTask)

local TasksBtnConnection = nil
local ButtonConnection = nil
local TaskPinBtnConnection = nil
local MainBackBtnConnection = nil
local BackBtnConnection = nil

local CurrentMission = {}

function CurrentMission.Init()
	CurrentMissionFrame.Visible = true
	print("Called")
	if TaskPinBtnConnection then TaskPinBtnConnection:Disconnect() end
	
	TasksBtnConnection = CurrentMissionFrame.MainFrame.ButtonFrame.Tasks.MouseButton1Down:Once(CurrentMission.OnTaskBtnClick)
	
end

-----------------------------------------------------------[TASKS]-------------------------------------------------------------

function CurrentMission.OnTaskBtnClick()
	game.SoundService.SFX.SecondaryClick:Play()

	CurrentMissionFrame.TasksFrame.Visible = true
	CurrentMission.LoadTasksIntoFrame()
end

local function FetchMissionFolder() --Gets the active mission folder
	if not Player:FindFirstChild("Missions") then
		warn("[CurrentMission]: Did not find Missions Folder. Waiting for it to be added")
		Player.ChildAdded:Wait()	
	end
	
	for i,folder in pairs(Player.Missions:GetChildren()) do
		if folder.Active.Value == true then
			return folder
		end
	end
end

local function GetTotalTaskIterations()
	--Gets how many times a quest or sub task is to be done to complete the task
end

local function GetCurrentCompletedIterations()

end

local function ClearChildren()
	for i,v in pairs(CurrentMissionFrame.TasksFrame.TasksDisplay:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

function CurrentMission.LoadTasksIntoFrame()
	local MissionFolder = FetchMissionFolder()
	ClearChildren()

	if not MissionFolder then return end

	for i,v in pairs(MissionFolder:GetChildren()) do
		if CollectionService:HasTag(v, "Task") then
			local TaskFrameClone = ReplicatedGui.Task:Clone()
			TaskFrameClone.Parent = CurrentMissionFrame.TasksFrame.TasksDisplay

			TaskFrameClone.Name = v.Name
			TaskFrameClone.TaskName.Text = v.Name

			TaskFrameClone.TaskDesc.Text = v:GetAttribute("Desc")

			if v.Completed.Value == true then
				TaskFrameClone.StatusDisplay.TextColor = BrickColor.new(0.333333, 1, 0)
				TaskFrameClone.StatusDisplay.Text = "Completed"

				TaskFrameClone.Completed.Visible = true
				TaskFrameClone.InProgress.Visible = false
			else
				if v.Active.Value == true then
					TaskFrameClone.StatusDisplay.TextColor = BrickColor.new(1, 0.333333, 0)

					TaskFrameClone.StatusDisplay.Text = "In Progress"

					TaskFrameClone.Completed.Visible = false
					TaskFrameClone.InProgress.Visible = true
				else
					TaskFrameClone.StatusDisplay.TextColor = BrickColor.new(0.513725, 0.513725, 0.513725)

					TaskFrameClone.StatusDisplay.Text = "Not Started"
					TaskFrameClone.Completed.Visible = false
					TaskFrameClone.InProgress.Visible = false
				end

				if TaskPinBtnConnection then TaskPinBtnConnection:Disconnect() end

				TaskPinBtnConnection = TaskFrameClone.PinBtn.MouseButton1Up:Connect(function()
					CurrentMission.PinTaskToDisplay(v)
				end)
			end
		end
	end
end

function CurrentMission.PinTaskToDisplay(Task)
	if not Task then warn("[CurrentMission]: Invalid Task Name to Pin!") return end
	
	
	game.SoundService.SFX.SecondaryClick:Play()
	PinTaskModule.Init(Task)
end

-----------------------------------------------------------[BackBtn]-------------------------------------------------------------

function CurrentMission.OnMissionFrameBackPressed()
	
	if MainBackBtnConnection then MainBackBtnConnection:Disconnect() end
	
	CurrentMissionFrame.Visible = false
	CurrentMissionFrame.Parent.MenuFrame.Visible = true
end

function CurrentMission.OnBackBtnPressed(Frame) --Frame: Frame to set to invisible
	if not Frame:IsA("Frame") then print("[CurrentMission]: Not a frame!") return end

	Frame.Visible = false
	CurrentMissionFrame.Visible = true -- a fallback just incase
end

task.spawn(function()
	if BackBtnConnection then BackBtnConnection:Disconnect() end
	for i,v in pairs(CurrentMissionFrame:GetChildren()) do
		if v:IsA("Frame") and v:FindFirstChild("BackBtn") and v.Name ~= "MainFrame" then --Might require a global connection variable
		 BackBtnConnection = v.BackBtn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				CurrentMission.OnBackBtnPressed(v)
			end)
		end
	end
end)

CurrentMissionFrame.MainFrame.BackBtn.MouseButton1Down:Connect(CurrentMission.OnMissionFrameBackPressed)

return CurrentMission