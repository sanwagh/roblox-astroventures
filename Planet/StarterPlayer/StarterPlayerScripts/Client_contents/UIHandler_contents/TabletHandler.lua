--[[
    TabletHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler
    Parent: UIHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("StarterGui")

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	
	self.TabletUI = self.PlayerGui:WaitForChild("TabletUI")
	self.MainMenuFrame = self.TabletUI.TabletFrame.ScreenFrame:WaitForChild("MainMenuFrame")
	self.MissionFrame = self.TabletUI.TabletFrame.ScreenFrame:WaitForChild("MissionFrame")
	
	--[MODULES]
	self.Animations = require(script.Animations)
	self.ModulesTable = {
		CurrentMission = require(script.CurrentMission).new(),
		Help = require(script.Help).new(),
		Settings = require(script.Settings).new(),
		Statistics = require(script.Statistics).new(),
	}

	self.InTablet = false
	self.LoggedIn = false
	self.LoginDebounce = false
	
	--[CONNECTIONS]
	self.MAINFRAME_BTN_CONNECTION = nil
	
	return self
end

function module:Init()
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.T then
				if not self.InTablet then
					game.SoundService.SFX.SecondaryClick:Play()
					CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

					self.InTablet = true
					self:ShowTablet()
					
					if self.LoggedIn then
						self:CheckForBtnClick()
					end
				else
					game.SoundService.SFX.SecondaryClick:Play()
					self:HideTablet()
					self.InTablet = false
					CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				end
			end
		end	
	end)
	
	-- Login Button Click
	
	self.TabletUI.TabletFrame.ScreenFrame.LoginFrame.InfoFrame.LoginBtn.MouseButton1Down:Once(function()
		if not self.LoginDebounce then
			self.LoginDebounce = true

			game.SoundService.SFX.Click:Play()
			self:OnLoginClicked()
			self:CheckForBtnClick()

			task.wait(3)
			self.LoginDebounce = false
		end
	end)
end

function module:ShowTablet()
	self.Animations.TabletOpenAnimation()

	self.TabletUI.TabletFrame.Visible = true
	self:LoadPlayerInfo()
end

function module:HideTablet()
	self.TabletUI.TabletFrame.Visible = false

	self.Animations.TabletCloseAnimation()
end

function module:OnLoginClicked()
	self.TabletUI.TabletFrame.ScreenFrame.LoginFrame.InfoFrame.LoginBtn.Text = "Processing..."
	task.wait(1)

	self.TabletUI.TabletFrame.ScreenFrame.LoginFrame.Visible = false
	self.TabletUI.TabletFrame.ScreenFrame.MainMenuFrame.Visible = true
end

function module:LoadPlayerInfo()
	self.TabletUI.TabletFrame.ScreenFrame.MissionFrame.PlayerInfoFrame.PlayerName.Text = self.Player.Name
	self.TabletUI.TabletFrame.ScreenFrame.MissionFrame.PlayerInfoFrame.PlayerPicture.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=420&h=420", self.Player.UserId)
end

function module:CheckForBtnClick()
	if self.MAINFRAME_BTN_CONNECTION then self.MAINFRAME_BTN_CONNECTION:Disconnect() end
	
	for i,btn in pairs(self.TabletUI.TabletFrame.ScreenFrame.MainMenuFrame.ButtonFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			self.MAINFRAME_BTN_CONNECTION = btn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				local Module = self.ModulesTable[btn.Name]
					Module:Init()
			end)
		end
	end
end

return module
