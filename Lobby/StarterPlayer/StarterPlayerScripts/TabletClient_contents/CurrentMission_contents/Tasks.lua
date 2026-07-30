--[[
    Tasks (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient → CurrentMission
    Parent: CurrentMission
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local TasksFrame = PlayerGui:WaitForChild("TabletUI").TabletFrame.ScreenFrame.MissionFrame.TasksFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceId = game.PlaceId --If it is the planet sub place, show sm stuff

local RefrestBtnConnection = nil
local BackBtnConnection = nil


local Tasks = {}

local function IsPlanetServer()
	if PlaceId == 140214143174948 then 
		return true
	else
		return false
	end
end


function Tasks.Init()
	TasksFrame.Visible = true

	Tasks.DisplayTasks()
	
	if RefrestBtnConnection then RefrestBtnConnection:Disconnect() end
	
	RefrestBtnConnection = TasksFrame.RefrestBtn.MouseButton1Click:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		Tasks.DisplayTasks()
	end)

	if not IsPlanetServer() then print("[Tasks]: Main Server, returning.") return end

end

local function GetActiveTaskFolder()
	for i,v in pairs(Player:FindFirstChild("Missions")) do
		if v.Active.Value == true then
			return v
		end
	end
end

local function ClearAllFrames()
	for i,v in pairs(TasksFrame.TasksDisplay:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

function Tasks.DisplayTasks()
	ClearAllFrames()
	task.wait(0.2)
	local ActiveMission = GetActiveTaskFolder()
	for i,v in pairs(ActiveMission:GetChildren()) do
		if v:HasTag("Task") then
			local TaskFrameClone = ReplicatedStorage.Gui.TaskDisplayFrame:Clone()
			TaskFrameClone.Name = v.Name
			TaskFrameClone.Parent = TasksFrame.TasksDisplay
			TaskFrameClone.TaskName.Text = v.Name
			TaskFrameClone.TaskDesc.Text = v:GetAttribute("Desc")
			TaskFrameClone.TaskStatus.Text = "Not Started"

			if not IsPlanetServer() then 
				Tasks.ShowStatus(v) --TODO: Make sure this updates everytime the tab is opened
			end
		end
	end
end

function Tasks.OnBackClicked()
	if BackBtnConnection then BackBtnConnection:Disconnect() end

		BackBtnConnection = TasksFrame.BackBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		TasksFrame.Visible = false
		TasksFrame.Parent.MainFrame.Visible = true
	end)
end

-- Functions not used in the lobby of the game

function Tasks.ShowStatus(Folder)
	if not Folder:HasTag("Task") then warn("[Tasks]: Did not receive a valid task", tostring(Folder)) return end

	if Folder.Completed.Value == true then
		TasksFrame.TaskDisplay:FindFirstChild(Folder.Name).TaskStatus.Text = "Completed"
		TasksFrame.TaskDisplay:FindFirstChild(Folder.Name).TaskStatus.TextColor3 = BrickColor.new(0, 1, 0.498039)
	elseif Folder.Active.Value == true then
		TasksFrame.TaskDisplay:FindFirstChild(Folder.Name).TaskStatus.Text = "Incomplete"
		TasksFrame.TaskDisplay:FindFirstChild(Folder.Name).TaskStatus.TextColor3 = BrickColor.new(1, 0, 0)
	end
end

return Tasks