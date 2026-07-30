--[[
    MainMenu (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule
    Parent: UIControllerModule
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenu")

local CameraHandler = require(script.Parent.Parent.Parent.Handlers.CameraHandler)
local LoadGameModule = require(script.LoadGame)
local NewGameModule = require(script.NewGame)

local MainMenu = {}

function MainMenu.IntroCompleted()
	MainMenuUI.MainMenuFrame.Visible = true
	MainMenu.OnDisplay()
	PlayerGui:WaitForChild("BugReportUI").OpenBugReport.Visible = true
end

function MainMenu.OnDisplay() 
	-- functionality for all the btns, and redirection to other modules.
	task.spawn(MainMenu.AnimateButtons)
	
	MainMenuUI.MainMenuFrame.ButtonFrame.LoadBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.Click:Play()
		MainMenu.LoadBtnClicked()
	end)
	MainMenuUI.MainMenuFrame.ButtonFrame.NewGameBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.Click:Play()
		MainMenu.NewGameBtnClicked()
	end)
end

function MainMenu.LoadBtnClicked()
	MainMenuUI.MainMenuFrame.Visible = false
	LoadGameModule.Show()
end

function MainMenu.NewGameBtnClicked()
	MainMenuUI.MainMenuFrame.Visible = false
	NewGameModule.Show()
end

function MainMenu.AnimateButtons()
	for i,v:TextButton in pairs(MainMenuUI.MainMenuFrame.ButtonFrame:GetChildren()) do
		if v:IsA("TextButton")  then
			v.MouseEnter:Connect(function()
				for i = 1,0,-0.1 do
					v.BackgroundTransparency = i
					task.wait(0.01)
				end
				v.TextColor = BrickColor.new(0, 0, 0)
			end)
			v.MouseLeave:Connect(function()
				for i = 0,1,0.1 do
					v.BackgroundTransparency = i
					task.wait(0.01)
				end
				v.TextColor = BrickColor.new(1, 1, 1)
			end)
		end
	end
end

return MainMenu