--[[
    Settings (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient
    Parent: TabletClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local SettingsFrame = PlayerGui.TabletUI.TabletFrame.ScreenFrame.SettingsFrame

local BackBtnConnection = nil

local Settings = {}

function Settings.Init()
	SettingsFrame.Visible = true
	SettingsFrame.Parent.MenuFrame.Visible = false
	
	Settings.OnBackClick()
end

function Settings.OnBackClick()
	SettingsFrame.BackBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		if BackBtnConnection then
			BackBtnConnection:Disconnect()
		end
		SettingsFrame.Visible = false
		SettingsFrame.Parent.MenuFrame.Visible = true
	end)
end


return Settings