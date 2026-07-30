--[[
    CurrentMission (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler → TabletHandler
    Parent: TabletHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module = {}
module.__index = module

--In the tasks module, add a log btn which will help the player log data

function module.new()
	local self = setmetatable({}, module)

	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")

	self.TabletUI = self.PlayerGui:WaitForChild("TabletUI")
	self.MainMenuFrame = self.TabletUI.TabletFrame.ScreenFrame:WaitForChild("MainMenuFrame")
	self.MissionFrame =  self.TabletUI.TabletFrame.ScreenFrame:WaitForChild("MissionFrame")
	self.MainFrame = self.MissionFrame.MainFrame --MainFrame in the MissionFrame

	self.ModulesTable = {
		Tasks = require(script.Tasks).new(),
		LogBook = require(script.LogBook).new(),
		MissionInfo = require(script.MissionInfo).new(),
		AbandonMission = require(script.AbandonMission).new(),
	}

	self.BTN_CONNECTION = nil
	self.BACK_BTN_CONNECTION = nil

	return self
end

function module:Init()
	self.MissionFrame.Visible = true
	self.MainMenuFrame.Visible = false
	
	self:BackButtonClick()
	self:LoadInformation()
	self:WaitForButtonClick()
end

function module:LoadInformation()
	self.MainFrame.MissionName.Text = self.Player.MissionName.Value
	self.MainFrame.SpaceshipName.Text = self.Player.SpaceshipName.Value
end

function module:WaitForButtonClick()
	if self.BTN_CONNECTION then self.BTN_CONNECTION:Disconnect() end

	for _, btn in pairs(self.MainFrame.ButtonFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			self.BTN_CONNECTION = btn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()

				local Module = self.ModulesTable[btn.Name].new()
				Module:Init()
			end)
		end
	end
end

function module:BackButtonClick()
	if self.BACK_BTN_CONNECTION then self.BACK_BTN_CONNECTION:Disconnect() end
	
	self.BACK_BTN_CONNECTION = self.MissionFrame.BackBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		
		self.MissionFrame.Visible = false
		self.MainMenuFrame.Visible = true
	end)
end


return module
