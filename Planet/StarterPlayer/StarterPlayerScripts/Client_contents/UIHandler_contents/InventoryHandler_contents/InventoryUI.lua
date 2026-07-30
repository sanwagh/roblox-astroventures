--[[
    InventoryUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler → InventoryHandler
    Parent: InventoryHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")
local Events = script.Parent.Parent.Parent.Events

local StarterGui = game:GetService("StarterGui")

local ErrorCodeModule = require(script.Parent.Parent.Parent.ClientErrorCodes)

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.BackpackUI = self.PlayerGui:WaitForChild("BackpackUI")
	self.InventoryFrame = self.BackpackUI:WaitForChild("InventoryFrame")
	self.HotbarFrame = self.BackpackUI:WaitForChild("HotbarFrame")

	self.Backpack = self.Player:WaitForChild("Backpack")
	
	self.ValuesFolder = script.Parent.Parent.Parent:WaitForChild("Values")

	
	self.UIS_BACKPACK_CONNECTION = nil
	self.BPCK_CLSE_CONNECTION = nil
	self.SLOT_CONNECTION = nil
	self.INV_BTN_CONNECTION = {}
	
	return self
end

function module:Init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	self:OnInventorySlotClick()
	self:LoadInventoryOnOpen()
	task.spawn(function()
		self:BindEvents()
	end)
	
end

function module:BindEvents()
	----------------------------------------------[UI Open]---------------------------------------------------------
	if self.UIS_BACKPACK_CONNECTION then self.UIS_BACKPACK_CONNECTION:Disconnect() end
	
	self.UIS_BACKPACK_CONNECTION = UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.E then
				self:OpenUI()
			end
		end	
	end)
	
	------------------------------------------------[UI close]---------------------------------------------------------
	if self.BPCK_CLSE_CONNECTION then self.BPCK_CLSE_CONNECTION:Disconnect() end
	
	self.BPCK_CLSE_CONNECTION = self.InventoryFrame.CloseBtn.MouseButton1Down:Connect(function()
		self:CloseUI()
	end)
	
	------------------------------------------------[Move Event]---------------------------------------------------------
	
	Events.ToInventory.OnInvoke = function(Slot)
		if not Slot then return end
		
		local Item = self.Player.Backpack:FindFirstChild(Slot.Data.ItemName.Value)
		
		if not Item then 
			warn("[ERROR] - ", ErrorCodeModule.CompileErrorMsg("GP2003HB"))
			return
		end
		
		self:MoveToInventory(Item)
	end
	
end

local function ClearSlotData(slot)
	slot.Data.ItemName.Value = ""
	slot.Data.ItemQuantity.Value = ""
	slot.Data.HasItem.Value = false

	slot.ItemDecal.Image = ""
	slot.QuantityDisplay.Text = ""
end

function module:OpenUI()
	game.SoundService.SFX.SecondaryClick:Play()
	self.InventoryFrame.Visible = true
	self.ValuesFolder.InventoryOpen.Value = true
end

function module:CloseUI()
	game.SoundService.SFX.SecondaryClick:Play()
	self.InventoryFrame.Visible = false
	self.ValuesFolder.InventoryOpen.Value = false

end

function ClearInventoryUI(InventoryFrame)
	for i,slot in pairs(InventoryFrame.InventorySlotFrame:GetChildren()) do
		if slot:IsA("ImageButton") then
			slot:Destroy()
		end
	end

	print("[InventoryUI]: Wiped all slots")
end

function LoadSlotInfo(slot, tool)
	slot.Data.HasItem.Value = true
	slot.Data.ItemName.Value = tool.Name
	slot.Data.ItemQuantity.Value = tool.Data.Quantity.Value

	slot.ItemDecal.Image = tool.Data.ImageId.Value
	slot.QuantityDisplay.Text = tool.Data.Quantity.Value
	slot.Name = tool.Name
end

function module:LoadInventoryOnOpen()
	ClearInventoryUI(self.InventoryFrame)
	
	for i, tool in pairs(self.Player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:GetAttribute("InHotbar") == false and tool:GetAttribute("Equipped") == false then
				if self.InventoryFrame.InventorySlotFrame:FindFirstChild(tool.Name) then
					warn("[ERROR] - "..ErrorCodeModule.CompileErrorMsg("GP2004"))
					
					continue
				end
				
				local SlotClone = ReplicatedGui.BackpackSlot:Clone()
				LoadSlotInfo(SlotClone, tool)
				SlotClone.Parent = self.InventoryFrame.InventorySlotFrame
			end
		end
	end
end

function module:OnInventorySlotClick()	
	--Disconnect all connections to prevent multiple event fires.
	self.InventoryFrame.InventorySlotFrame.ChildAdded:Connect(function()
		
		for i, conn in pairs(self.INV_BTN_CONNECTION) do
			conn:Disconnect()
		end
		
		for i, slot in pairs(self.InventoryFrame.InventorySlotFrame:GetChildren()) do
			if slot:IsA("ImageButton") then
				local conn = slot.MouseButton1Down:Connect(function()
					game.SoundService.SFX.Click:Play()
					
					local Item = self.Player.Backpack:FindFirstChild(slot.Data.ItemName.Value)
					
					if not Item then
						warn("[ERROR] - ", ErrorCodeModule.CompileErrorMsg("GP2003HB"))
						return
					end
					
					Events.ToHotbar:Invoke(slot)
				end)
				table.insert(self.INV_BTN_CONNECTION, conn)
			end
		end
	end)
end

function module:MoveToInventory(Item)
	if self.InventoryFrame.InventorySlotFrame:FindFirstChild(Item.Name) then
		warn("[ERROR] - "..ErrorCodeModule.CompileErrorMsg("GP2004"))
		
		return
	end
	
	local SlotClone = ReplicatedGui.BackpackSlot:Clone()
	
	LoadSlotInfo(SlotClone, Item)
	SlotClone.Parent = self.InventoryFrame.InventorySlotFrame
end


return module
