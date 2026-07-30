--[[
    Tasks (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler → TabletHandler → CurrentMission
    Parent: CurrentMission
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")

local module = {}
module.__index = module

--TODO:LAST_LEFT(20/01): Test The tasks display function

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")

	self.TabletUI = self.PlayerGui:WaitForChild("TabletUI")
	self.MissionFrame = self.TabletUI.TabletFrame.ScreenFrame:WaitForChild("MissionFrame")
	self.TasksFrame = self.MissionFrame:WaitForChild("TasksFrame")
	
	self.REFRESH_BTN_CONNECTION = nil
	self.BACK_BTN_CONNECTION = nil
	
	return self
end

function module:Init()
	self.TasksFrame.Visible = true
	--self.MissionFrame.Visible = false
	
	self:DisplayTasks()
	
	if self.REFRESH_BTN_CONNECTION then self.REFRESH_BTN_CONNECTION:Disconnect() end
	
	self.REFRESH_BTN_CONNECTION = self.TasksFrame.RefreshBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self:DisplayTasks()
	end)

	if self.BACK_BTN_CONNECTION then self.BACK_BTN_CONNECTION:Disconnect() end
	self.BACK_BTN_CONNECTION = self.TasksFrame.BackBtn.MouseButton1Down:Connect(function()
		self:OnBackBtnClicked()
	end)
end

function module:ClearAllFrames()
	for _,v in pairs(self.TasksFrame.TasksDisplay:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

function module:DisplayTasks()
	self:ClearAllFrames()
	local Data = RemoteFunctions.FetchData:InvokeServer()	

	local MissionData = Data[self.Player.MissionName.Value.."Data"]
	if not MissionData then warn("[Tasks] Mission not found,", MissionData, self.Player.MissionName.Value) return end
	
	local TasksTable = MissionData["Tasks"]
	if not TasksTable then warn("[Tasks] Tasks not found,", MissionData, self.Player.MissionName.Value) return end

	for i,v in pairs(TasksTable) do
		local TaskFrameClone = ReplicatedStorage.Gui.TaskDisplayFrame:Clone()
		TaskFrameClone.Name = i
		TaskFrameClone.Parent = self.TasksFrame.TasksDisplay
		TaskFrameClone.TaskName.Text = i
		TaskFrameClone.TaskDesc.Text = v["Desc"]
		self:GetTaskStatus(i)
	end
end

function module:GetTaskStatus(Task)
	if Task["Completed"] == true then
		self.TasksFrame.TasksDisplay:FindFirstChild(Task).TaskStatus.Text = "Completed"
		self.TasksFrame.TasksDisplay:FindFirstChild(Task).TaskStatus.TextColor3 = Color3.new(0, 1, 0.498039)
	else
		self.TasksFrame.TasksDisplay:FindFirstChild(Task).TaskStatus.Text = "Incompleted"
		self.TasksFrame.TasksDisplay:FindFirstChild(Task).TaskStatus.TextColor3 = Color3.new(1,0,0)
	end
end

function module:OnBackBtnClicked()
	game.SoundService.SFX.SecondaryClick:Play()
	self.TasksFrame.Visible = false
	self.MissionFrame.MainFrame.Visible = true
end

return module
