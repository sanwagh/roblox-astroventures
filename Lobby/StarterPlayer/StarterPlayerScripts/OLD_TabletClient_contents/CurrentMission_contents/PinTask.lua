--[[
    PinTask (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → [OLD]TabletClient → CurrentMission
    Parent: CurrentMission
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local PinTaskFrame = PlayerGui:WaitForChild("TabletUI").PinFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.1)
local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")

local MAX_PINS = 6

local PropertyChangeSignalConnection = nil
local RemoveBtnConnection = nil

local PinTask = {}

local function GetPinnedTasks()
	local count = 0
	for i,v in pairs(PinTaskFrame.TaskFrame:GetChildren()) do
		if v:IsA("Frame") then
			count += 1
		end
	end

	return count
end

local function CheckForPinned()

	if GetPinnedTasks() > 0 then
		PinTaskFrame.Visible = true
	else
		PinTaskFrame.Visible = false
	end
end

function PinTask.Init(Task)
	PinTask.Pin(Task)

	CheckForPinned()	
	task.spawn(PinTask.UpdateTaskFrameData,Task)
end

local function GetMaxIterations(Task)
	local count = 0

	for i,v in pairs(Task:GetChildren()) do
		if CollectionService:HasTag(v, "Iteration") then
			count += 1
		end
	end
	
	return count
end

local function GetCompletedIterations(Task)
	local count = 0

	for i,v in pairs(Task:GetChildren()) do
		if CollectionService:HasTag(v, "Iteration") then
			if v.Value ~= nil or v.Value ~= "" then
				count += 1
			end
		end
	end
	return count
end

local function ManageIterations(TaskFrameClone, Task)
	local MaxIterations = GetMaxIterations(Task)
	local CompletedIterations = GetCompletedIterations(Task)
	
	if CompletedIterations < MaxIterations then
		TaskFrameClone.TaskStatus.TextColor = BrickColor.new(1, 1, 0.498039)

		TaskFrameClone.TaskStatus.Text = "Status: "..CompletedIterations.."/"..MaxIterations.." completed"
	else
		TaskFrameClone.TaskStatus.TextColor = BrickColor.new(0.333333, 1, 0)
		TaskFrameClone.TaskStatus.Text = "Status: Completed"
		TaskFrameClone.Completed.Visible = true
	end
end

local function CheckIfPinned(Task)
	warn(Task, typeof(Task))

	for i,v in pairs(PinTaskFrame.TaskFrame:GetChildren()) do
		if v:IsA("Frame") then
			if v.Name == Task.Name then
				return true
			end
		end
	end
	return false
end


function PinTask.Pin(Task)
	--Clone and pin and display the status
	warn(Task, typeof(Task))
	
	task.spawn(PinTask.CheckForTaskRemoval)
	
	if CheckIfPinned(Task) then return end
	
	local TaskFrameClone = ReplicatedGui.TaskDisplayFrame:Clone()
	TaskFrameClone.Parent = PinTaskFrame.TaskFrame

	TaskFrameClone.Name = Task.Name
	TaskFrameClone.TaskName.Text = Task.Name

	TaskFrameClone.TaskDesc.Text = Task:GetAttribute("Desc")
	
	ManageIterations(TaskFrameClone, Task)	
end

local function GetTaskFrame(Task)
	for i,v in pairs(PinTaskFrame.TaskFrame:GetChildren()) do
		if v:IsA("Frame") then
			if v.Name == Task.Name then
				print("Found")
				
				return v
				
			end
		end
	end
	print("Not Found: ", tostring(Task))
end

function PinTask.UpdateTaskFrameData(Task)

	for i,v in pairs(Task:GetChildren()) do
		if CollectionService:HasTag(v, "Iteration") then
			v:GetPropertyChangedSignal("Value"):Connect(function()
				ManageIterations(GetTaskFrame(Task), Task)
			end)
		end
	end
end

function PinTask.RemovePin(frame)
	
	local Tween = TweenService:Create(frame, Tweeninfo, {Position = UDim2.new(0,0,-0.5,0)})
	
	Tween:Play()
	Tween.Completed:Wait()
	frame:Destory()

	CheckForPinned()
end

function PinTask.CheckForTaskRemoval()
	if RemoveBtnConnection then RemoveBtnConnection:Disconnect() end
	
	for i,v in pairs(PinTaskFrame.TaskFrame:GetChildren()) do
		if v:IsA("Frame") then
			RemoveBtnConnection = v.RemoveBtn.MouseBtn1Down:Once(function()
				game.SoundService.SFX.SecondaryClick:Play()
				PinTask.RemovePin(v)
			end)
		end
	end
end

return PinTask
