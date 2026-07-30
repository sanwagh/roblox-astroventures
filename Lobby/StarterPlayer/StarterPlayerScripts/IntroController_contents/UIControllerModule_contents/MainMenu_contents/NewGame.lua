--[[
    NewGame (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule → MainMenu
    Parent: MainMenu
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenu")

local PostLoading = require(script.Parent.PostLoading)

local SlotData = {}
local NewGame = {}

local Debounce = false

-- Connections
local NextBtnConnection = nil
local CancelBtnConnection = nil
local CreateBtnConnection = nil

-- Use connections in module scripts while connecting it to a btn or any :Connect() event

function NewGame.Show()
	MainMenuUI.NewGameFrame.Visible = true
	MainMenuUI.MainMenuFrame.Visible = false
	MainMenuUI.NewGameFrame.NameFrame.Visible = true
	NewGame.SetSlotName()
end

function GetName()
	return MainMenuUI.NewGameFrame.NameFrame.SlotName.Text
end

function NewGame.SetSlotName()
	-- When the next button is clicked, the name is fetched using GetName() and sets the NameFrame to false and sets the DiffFrame true

	if NextBtnConnection then NextBtnConnection:Disconnect() end
	if CancelBtnConnection then CancelBtnConnection:Disconnect() end


	NextBtnConnection = MainMenuUI.NewGameFrame.NameFrame.NextBtn.MouseButton1Down:Once(function()
		game.SoundService.SFX.Click:Play()
		local SlotName = GetName()
		print(SlotName)
		MainMenuUI.NewGameFrame.NameFrame.Visible = false
		MainMenuUI.NewGameFrame.DifficultyFrame.Visible = true
		table.insert(SlotData, SlotName)

		NewGame.SetDifficulty()
	end)

	CancelBtnConnection = MainMenuUI.NewGameFrame.NameFrame.CancelBtn.MouseButton1Down:Once(function()
		game.SoundService.SFX.Click:Play()
		MainMenuUI.NewGameFrame.Visible = false
		MainMenuUI.MainMenuFrame.Visible = true
		MainMenuUI.NewGameFrame.NameFrame.Visible = false
	end)
end


function SelectDifficulty()
	-- loop thru all the difficulty labels and on click, set them their atr to true and others to false.
	for i,v in pairs(MainMenuUI.NewGameFrame.DifficultyFrame.Difficulty:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Down:Connect(function()
				game.SoundService.SFX.Click:Play()

				for _,btn:TextButton in pairs(MainMenuUI.NewGameFrame.DifficultyFrame.Difficulty:GetChildren()) do
					if btn:IsA("TextButton") then
						btn:SetAttribute("Selected", false)
						btn.CheckedBox.Visible = false
					end
				end

				v:SetAttribute("Selected", true)
				v.CheckedBox.Visible = true
			end)
		end
	end	
end

function GetDifficulty()
	for i,v in pairs(MainMenuUI.NewGameFrame.DifficultyFrame.Difficulty:GetChildren()) do
		if v:IsA("TextButton") then
			if v:GetAttribute("Selected") == true then
				return v.Name
			end
		end
	end
end

function NewGame.SetDifficulty()
	task.spawn(SelectDifficulty)
	
	if CreateBtnConnection then CreateBtnConnection:Disconnect() end

	CreateBtnConnection = MainMenuUI.NewGameFrame.DifficultyFrame.CreateBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.Click:Play()

		local Difficulty = GetDifficulty()
		table.insert(SlotData, Difficulty)	
		NewGame.SendDataToServer()
		PostLoading.OnLoaded()
	end)
end

function NewGame.SendDataToServer()
	if not Debounce then
		Debounce = true
		print("[NewGame]: Sending Slot Creation Data to the Server for moderation and creation...")
		game.ReplicatedStorage.RemoteEvents.SlotChangeRequest:FireServer("Create", SlotData[1], SlotData[2]) --[1]: SLT_NAME [2]: Difficulty
		task.wait(1)
		Debounce = false
	end

end

return NewGame