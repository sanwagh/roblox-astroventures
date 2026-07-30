--[[
    ShopHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → ShopUIClient
    Parent: ShopUIClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--Handles the functioning of both the shop and the owned items

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.ShopUIModule = require(script.Parent.ShopUI).new()
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.ShopUI = self.PlayerGui:WaitForChild("ShopUI")
	self.ShopFrame = self.ShopUI.ShopFrame
	self.CartFrame = self.ShopFrame.MainFrame.CartFrame
	self.ItemsFrame = self.ShopFrame.MainFrame.ItemsFrame
	self.DisplayTitle = self.ShopFrame.MainFrame.DisplayTitle
	self.CloseBtn = self.ShopFrame.CloseBtn
	
	self.ItemsFolder = nil
	self.UtilitiesFolder = game.Workspace:WaitForChild("Utilities")
	
	self.FETCH_ITEM_DATA_CONNECTION = nil
	
	return self
end

function module:Init()
	self:BindEvents()
	self.ShopUIModule:Init()
end

function module:BindEvents()
	-- Add the proximity Prompts here
	self.UtilitiesFolder.ToolStore.ProximityPart.ProximityPrompt.Triggered:Connect(function()
		self.ShopUIModule:OpenShopUI()
	end)
end

return module
