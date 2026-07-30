--[[
    BuildMenuHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler
    Parent: UIHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local UserInputService = game:GetService("UserInputService")

local BuildMenuHandler = {}
BuildMenuHandler.__index = BuildMenuHandler

function BuildMenuHandler.new()
	local self = setmetatable({}, BuildMenuHandler)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.BuildMenuUI = self.PlayerGui:WaitForChild("BuildMenuUI")
	
	self.OPEN_BTN_CONNECTION = nil
	return self
end

function BuildMenuHandler:Init()
	self:WaitForUserInput()
end

function BuildMenuHandler:WaitForUserInput()
	if self.OPEN_BTN_CONNECTION then self.OPEN_BTN_CONNECTION:Disconnect() end
	
	self.OPEN_BTN_CONNECTION = UserInputService.InputBegan:Connect(function(input, GameProcesssed)
		if not GameProcesssed then
			if input.KeyCode ==	Enum.KeyCode.B then
				game.SoundService.SFX.Click:Play()
				self:OpenUI()
				self:BindUIInputs()
			end
		end
	end)
end

function BuildMenuHandler:OpenUI()
	self.BuildMenuUI.Visible = true
end

function BuildMenuHandler:BindUIInputs()
	task.spawn(function()
		self:WaitForItemFrameClick()
	end)
end

function BuildMenuHandler:WaitForItemFrameClick()
	-- When an item frame in the build list is clicked
	for i, frame in pairs(self.BuildMenuUI.BuildFrame.BuildItemsFrames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.ItemBtn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				print("[BuildMenuHandler]: Init placement engine")
				self:InitPlacementEngine()
			end)
		end
	end
end

function BuildMenuHandler:InitPlacementEngine()
	-- Goes into placement and build mode
	
end

return BuildMenuHandler