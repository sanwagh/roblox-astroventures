--[[
    OwnedItemsUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → ShopUIClient
    Parent: ShopUIClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--TODO:IMP  server sided code

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gui = ReplicatedStorage:WaitForChild("Gui")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)

	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.ShopUI = self.PlayerGui:WaitForChild("ShopUI")
	self.ShopFrame = self.ShopUI.ShopFrame
	self.CartFrame = self.ShopFrame.MainFrame.CartFrame
	self.ItemsFrame = self.ShopFrame.MainFrame.ItemsFrame
	self.OwnedItemsFrame = self.ShopUI.ShopFrame.MainFrame.OwnedItemsFrame

	self.LOC_BTN_CONNECTIONS = {}
	return self
end

function module:Init()
	-- Blank Function
end

--Showing of shop and the btn binding is one in the ShopUI Script
function module:ShowUI()
	self.OwnedItemsFrame.Visible = true
	self.ItemsFrame.Visible = false
	self.CartFrame.Visible = false
	
	self:DisplayOwnedItems()
	self:ChangeItemStorageLocOnBtnEvent()
end

local function ClearItemFrames(OwnedItemsDisplay)
	for i, frame in pairs(OwnedItemsDisplay:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function module:DisplayOwnedItems()
	-- Displays everything in the players backpack
	ClearItemFrames(self.OwnedItemsFrame.OwnedItemsDisplay)

	for i, tool in pairs(self.Player.Backpack:GetChildren()) do
		local FrameClone = Gui.OwnedItemFrame:Clone()
		FrameClone.Name = tool.Name --Passed on to the server later on
		FrameClone.ItemName.Text = tool.Data.DisplayName.Value
		FrameClone.QuantityLabel.Text = "Quantity: "..tool.Data.Quantity.Value
		FrameClone.Parent = self.OwnedItemsFrame.OwnedItemsDisplay
		
		if tool.Data.InStorage.Value == false then
			FrameClone.StorageLocLabel.TextColor = BrickColor.new(0, 1, 0)
			FrameClone.StorageLocLabel.Text = "In Inventory"
		else
			FrameClone.StorageLocLabel.TextColor = BrickColor.new(255,85,0)
			FrameClone.StorageLocLabel.Text = "In Storage"

		end
	end
end

function module:ChangeItemStorageLocOnBtnEvent()

	-- Prevents double trigger for btns
	for i, conn in pairs(self.LOC_BTN_CONNECTIONS) do
		conn:Disconnect()
	end

	self.LOC_BTN_CONNECTIONS = {}

	for i, frame in pairs(self.OwnedItemsFrame.OwnedItemsDisplay:GetChildren()) do
		if frame:IsA("Frame") then
			local Connection = frame.MoveStorageLocBtn.MouseButton1Down:Connect(function()
				--Add a debounce
				game.SoundService.SFX.SecondaryClick:Play()
				local Status, Message = RemoteFunctions.ChangeItemStorageLoc:InvokeServer(frame.Name)
				if Status == true then
					frame.MoveStorageLocBtn.Text = "Move to "..Message

					if Message == "Inventory" then
						frame.StorageLocLabel.TextColor = BrickColor.new(0, 1, 0)
						frame.StorageLocLabel.Text = "In Inventory"

					else
						frame.StorageLocLabel.TextColor = BrickColor.new(255,85,0)
						frame.StorageLocLabel.Text = "In Storage"

					end
				else
					warn("Failed to change location of item: "..Message)
				end
			end)

			table.insert(self.LOC_BTN_CONNECTIONS, Connection)
		end
	end
end

return module
