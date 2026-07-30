--[[
    [OLD]TabletClient (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: true
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer

local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local TabletUI = PlayerGui:WaitForChild("TabletUI")

local CoreGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Animations = require(script.Animations)

local InTablet = false
local LoginDebounce = false
local LoggedIn = false

local MainFrameButtonConnection = nil

local function ShowTabletUI()
	Animations.TabletOpenAnimation()
	
	TabletUI.TabletFrame.Visible = true
end

local function HideTabletUI()
	TabletUI.TabletFrame.Visible = false

	Animations.TabletCloseAnimation()
end

local function OnLoginClicked()
	TabletUI.TabletFrame.ScreenFrame.LoginFrame.InfoFrame.LoginBtn.Text = "Processing..."
	task.wait(2)
	
	TabletUI.TabletFrame.ScreenFrame.LoginFrame.Visible = false
	TabletUI.TabletFrame.ScreenFrame.MenuFrame.Visible = true
end

local function CheckForBtnClick() 
	warn("call")
	if MainFrameButtonConnection then MainFrameButtonConnection:Disconnect() end
	
	for i,v in pairs(TabletUI.TabletFrame.ScreenFrame.MenuFrame.ButtonFrame:GetChildren()) do
		if v:IsA("TextButton") then
			MainFrameButtonConnection = v.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				print(v.Name)
				local Module = require(script:FindFirstChild(v.Name))
				Module.Init()
			end)
		end
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
	if not gameProcessedEvent then
		if input.KeyCode == Enum.KeyCode.T then
			if not InTablet then
				game.SoundService.SFX.SecondaryClick:Play()
				CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

				InTablet = true
				ShowTabletUI()
				if LoggedIn then
					CheckForBtnClick()
				end
			else
				game.SoundService.SFX.SecondaryClick:Play()
				HideTabletUI()
				InTablet = false
				CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
			end
		end
	end	
end)

TabletUI.TabletFrame.ScreenFrame.LoginFrame.InfoFrame.LoginBtn.MouseButton1Down:Once(function()
	if not LoginDebounce then
		LoginDebounce = true
		
		game.SoundService.SFX.Click:Play()
		OnLoginClicked()
		CheckForBtnClick()
		
		task.wait(3)
		LoginDebounce = false
	end
end)