--[[
    HotbarUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler → InventoryHandler
    Parent: InventoryHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

-- Handles loading for hotbar, equip related and moving to and from the inventory

local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")
local Events = script.Parent.Parent.Parent.Events

local ErrorCodeModule = require(script.Parent.Parent.Parent.ClientErrorCodes)

local HotbarUI = {}
HotbarUI.__index = HotbarUI

function HotbarUI.new()
	local self = setmetatable({}, HotbarUI)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.BackpackUI = self.PlayerGui:WaitForChild("BackpackUI")
	self.InventoryFrame = self.BackpackUI:WaitForChild("InventoryFrame")
	self.HotbarFrame = self.BackpackUI:WaitForChild("HotbarFrame")

	self.Backpack = self.Player:WaitForChild("Backpack")
	
	self.ValuesFolder = script.Parent.Parent.Parent:WaitForChild("Values")

	self.HotbarEventListened = false
	
	self.UIS_EQUIP_CONENCTION = nil
	
	return self
end

function HotbarUI:Init()
	
		self:BindEvents()
	
	self:OnSlotClick()
end

function HotbarUI:BindEvents()
	
	print("before BFunc")

	Events.ToHotbar.OnInvoke = function(Slot)
		print("Callback")
		if not Slot then print(Slot) return end

		print("move to hb")
		self:MoveToHotbar(Slot)
		return "Finished"
	end
	
	-- Loading Hotbar
	task.spawn(function()
		ReplicatedStorage.RemoteEvents.DataLoaded.OnClientEvent:Connect(function()
			if self.HotbarEventListened then return end

			self.HotbarEventListened = true

			self:LoadHotbar()
		end)

		if not self.HotbarEventListened then
			while self.ValuesFolder.DataLoaded.Value == false do
				task.wait()
			end
			self.HotbarEventListened = true
			self:LoadHotbar()
		end

	end)
	
	-- Equip function
	task.spawn(function()
		self:EquipItem()
	end)
	
	
end

function HotbarUI:LoadHotbar()
	--TODO ADD HB ITEM CHECK GP2001
	for i, tool in pairs(self.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:GetAttribute("InHotbar") == false then continue end
			
			for i, slot in pairs(self.HotbarFrame:GetChildren()) do
				if slot:IsA("ImageButton") then
					if slot.Data.HasItem.Value == false then
						slot.Data.HasItem.Value = true
						slot.Data.ItemName.Value = tool.Name
						slot.Data.ItemQuantity.Value = tool.Data.Quantity.Value
						slot.ItemDecal.Image = tool.Data.ImageId.Value
						slot.QuantityDisplay.Text = tool.Data.Quantity.Value
						break
					end
				end
			end
		end
	end
end

function HotbarUI:UnequipItem(Item)
	RemoteEvents.InventoryEvent:FireServer("Unequip", Item)
	self.Player.Character.EquippedItem.Value = ""
end


function HotbarUI:EquipItem()
	self.UIS_EQUIP_CONNECTION = UIS.InputBegan:Connect(function(input, GameProcessedEvent)
		if not GameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.One then
				local Slot = self.HotbarFrame.Slot1
				self:SendEquipRequest(Slot)
			
			elseif input.KeyCode == Enum.KeyCode.Two then
				local Slot = self.HotbarFrame.Slot2
				self:SendEquipRequest(Slot)
				
			elseif input.KeyCode == Enum.KeyCode.Three then
				local Slot = self.HotbarFrame.Slot3
				self:SendEquipRequest(Slot)
			
			end
		end
	end)
end

function HotbarUI:SendEquipRequest(Slot)
	local Char = self.Player.Character

	

	if Slot.Data.HasItem.Value == false then
		return
	end

	local Item = self.Player.Backpack:FindFirstChild(Slot.Data.ItemName.Value)

	if Char.EquippedItem.Value == Slot.Data.ItemName.Value then
		local Item = self.Player.Character:FindFirstChild(Slot.Data.ItemName.Value)
		self:UnequipItem(Item)
		return
	end

	if not Item then 
		return
	end

	if Char.EquippedItem.Value ~= "" then
		print("Unequip", Char.EquippedItem.Value)
		self:UnequipItem(Item)
	end

	RemoteEvents.InventoryEvent:FireServer("Equip", Item)
	Char.EquippedItem.Value = Item.Name
end


function HotbarUI:OnSlotClick()
	-- Fire a bindable event with the slot (hb) and move
	for i, slot in pairs(self.HotbarFrame:GetChildren()) do
		if slot:IsA("ImageButton") then
			slot.MouseButton1Down:Connect(function()
				-- if inventory is open, move stuff
				if self.ValuesFolder.InventoryOpen.Value ~= true then 
					return
				end
				
				if slot.Data.HasItem.Value == false then 
					return
				end
				
				self:ReqMoveToInventory(slot)
			end)
		end
	end
end

--Single call functions. Do not call multiple times---------
function HotbarUI:ReqMoveToInventory(Slot)
	Events.ToInventory:Invoke(Slot) --slot
	
	-- Erase Slot Data
	Slot.Data.HasItem.Value = false
	Slot.Data.ItemName.Value = ""
	Slot.Data.ItemQuantity.Value = 0
	Slot.ItemDecal.Image = ""
	Slot.QuantityDisplay.Text = ""
end

function HotbarUI:MoveToHotbar(InvSlot)
	-- Handles the moving of item into the hb after processing request
	if not InvSlot then 
		return
	end
	
	local Slot = self:GetFreeHotbarSlot()
	
	if not Slot then 
		return
	end
	
	local Item = self.Player.Backpack:FindFirstChild(InvSlot.Data.ItemName.Value)
	
	if not Item then
		warn("[ERROR] - ", ErrorCodeModule.CompileErrorMsg("GP2003INV"))
		return
	end 
	
	Slot.Data.HasItem.Value = true
	Slot.Data.ItemName.Value = Item.Name
	Slot.Data.ItemQuantity.Value = Item.Data.Quantity.Value
	Slot.ItemDecal.Image = Item.Data.ImageId.Value
	Slot.QuantityDisplay.Text = Item.Data.Quantity.Value
	
	InvSlot:Destroy()
	print("DEBUG: Moved to Hotbar")
end

function HotbarUI:GetFreeHotbarSlot()
	for i, slot in pairs(self.HotbarFrame:GetChildren()) do
		if slot:IsA("ImageButton") then
			if slot.Data.HasItem.Value == false then
				return slot
			end
		end
	end
	print("DEBUG: No free slot found in Hotbar")
	return false
end

return HotbarUI