--[[
    CurrentMission (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient
    Parent: TabletClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MissionFrame = PlayerGui:WaitForChild("TabletUI").TabletFrame.ScreenFrame.MissionFrame

local ButtonConnection = nil
local BackButtonConnection = nil

local CurrentMission = {}

local Modules = {
	AbandonMission = require(script.AbandonMission),
	MissionInfo = require(script.MissionInfo),
	Statistics = require(script.Statistics),
	Tasks = require(script.Tasks),
}

-- Displays the mission name and spaceship used, 2 buttons, Mission Info and tasks
-- Mission info: Show the planet info and spaceship used
--Tasks: Shows the tasks
function CurrentMission.Init()
	MissionFrame.Visible = true
	MissionFrame.Parent.MenuFrame.Visible = false
	
	if not Player:FindFirstChild("MissionName") then
		print("did not find mission value")
		MissionFrame.MainFrame.Visible = false
		MissionFrame.SelectMissionTxt.Visible = true
	else
		print("found")
	end
	
	CurrentMission.LoadInformation()
end

function CurrentMission.LoadInformation()
	--Loads mission name and spaceship etc
	MissionFrame.MainFrame.MissionName.Text = Player.MissionName.Value
	MissionFrame.MainFrame.SpaceshipName.Text = Player.SpaceshipName.Value
end

function CurrentMission.WaitForButtonClick()
	if ButtonConnection then ButtonConnection:Disconnect() end
	for i, btn in pairs(MissionFrame.ButtonFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			ButtonConnection = btn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()

				local Module = Modules[btn.Name] 
				if not Module then warn("[CurrentMission]: Could not find script named", btn.Name) return end
				print("[CurrentMission]: Calling", Module.Name)
				Module.Init()
			end)
		end
	end
end

function CurrentMission.OnBackClick()
	game.SoundService.SFX.SecondaryClick:Play()
	MissionFrame.Visible = false
	MissionFrame.Parent.MenuFrame.Visible = true

end

MissionFrame.BackBtn.MouseButton1Down:Connect(function()
	CurrentMission.OnBackClick()
end)

return CurrentMission