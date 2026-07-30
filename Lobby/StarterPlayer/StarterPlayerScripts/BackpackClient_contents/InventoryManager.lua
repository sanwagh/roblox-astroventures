--[[
    InventoryManager (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → BackpackClient
    Parent: BackpackClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player:Player = game.Players.LocalPlayer

local StarterGear:StarterGear = Player:WaitForChild("Backpack") -- Data is fetched from Backpack on the server and not SG
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local BackpackUI = PlayerGui:WaitForChild("BackpackUI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.1)

local HotbarManager = require(script.Parent.HotbarManager)
local Values = require(script.Parent.Parent.Values)

local Mouse = Player:GetMouse()

local MAX_SLOTS = 30

local InventoryManager = {}

local function GetTotalInventorySlots()
	local Slots = 0
	for i,slot in pairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if slot:IsA("ImageButton") then
			Slots += 1
		end
	end
	return Slots
end

function InventoryManager.ClearInventorySlots()
	for i,slots in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if slots:IsA("ImageButton") then
			slots:Destroy()
		end
	end
	print("[InventoryManager]: Cleared all slots in Backpack")
end

local function AddSlot(item)
	local Slot = ReplicatedGui.BackpackSlot:Clone()
	Slot.Name = item.Name
	Slot.QuantityDisplay.Text = item.Data.Quantity.Value
	Slot.HasItem.Value = true
	Slot.ItemDecal.Image = item.Data.ImageId.Value
	Slot.Parent = BackpackUI.BackpackFrame.BackpackSlotFrame
end

local function AddBlankSlot()
	local Slot = ReplicatedGui.BackpackSlot:Clone()
	Slot.Parent = BackpackUI.BackpackFrame.BackpackSlotFrame
	
	return Slot	
end

function InventoryManager.LoadInventory()
	
	 InventoryManager.ClearInventorySlots()
	
	for i, tool in ipairs(StarterGear:GetChildren()) do
		if tool:GetAttribute("InHotbar") == false then
			if not BackpackUI.BackpackFrame.BackpackSlotFrame:FindFirstChild(tool.Name) then
				print("Tool not there")
				AddSlot(tool)
			else
				print("Tool there, incrementing")
				BackpackUI.BackpackFrame.BackpackSlotFrame:FindFirstChild(tool.Name).QuantityDisplay.Text = tool.Data.Quantity.Value
			end
		end
	end
end

local function UpdateHotbarQuantities()
	for i,v in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			if v.Data.HasItem.Value == true then
				local Item = StarterGear:FindFirstChild(v.Data.ItemName.Value)
				v.Data.ItemQuantity.Value = Item.Data.Quantity.Value
				v.QuantityDisplay.Text = Item.Data.Quantity.Value
			end
		end
	end
end

local function ClearHotbarSlot(HotbarSlot)
	HotbarSlot.Data.HasItem.Value = false
	HotbarSlot.ItemDecal.Image = ""
	HotbarSlot.QuantityDisplay.Text = ""
	HotbarSlot.Data.ItemQuantity.Value = 0
	HotbarSlot.Data. ItemName.Value = ""
end

local function FindEmptySlotInHotbar()
	for i,slot in ipairs(BackpackUI.HotbarFrame:GetChildren()) do
		if slot:IsA("ImageButton") then
			if slot.Data.HasItem.Value == false then
				return slot
			end
		end
	end
	return nil
end

--local function FindEmptySlotInInventory()
--	for i,slot in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
--		if slot:IsA("ImageButton") then
--			if slot.HasItem.Value == false then
--				return slot
--			end
--		end
--	end
--	return nil
--end

local function GetInventorySlotFromItem(item)
	local ItemName
	for i,v in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			if v.Name == tostring(item) then
				return v
			end
		end
	end
	return nil
end

local function GetInventoryItemFromSlot(slot)
	for i,v in ipairs(StarterGear:GetChildren()) do
		if v.Name == slot.Name then
			return v
		end
	end
end

local function GetHotbarSlotFromItem(item)
	local ItemName
	for i,v in ipairs(BackpackUI.HotbarFrame:GetChildren()) do
		if v:IsA("ImageButton") and v.Data.ItemName.Value == item.Name then
			return v
		end
	end
end

local function GetHotbarItem(slot)
	print(slot)
	if StarterGear:FindFirstChild(slot.Data.ItemName.Value) then
		return StarterGear:FindFirstChild(slot.Data.ItemName.Value)
	else
		warn("[InventoryManager]: Did not find the item in the slot in players stored inventory")
		return nil
	end
end

local function GetLastInventorySlot()
	local LastSlot
	for i,v in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			LastSlot = v
		end
	end
	return LastSlot
end

function InventoryManager.MoveSelectedItemToHotbar(ItemInHotbar)
	-- CALLED BY THE MAIN SCRIPT 
	print("TO HOTBAR")
	local HotbarSlot = FindEmptySlotInHotbar()
	
	if not HotbarSlot then
		local InventorySlot 
		
		if GetTotalInventorySlots() < MAX_SLOTS then
			InventorySlot = AddBlankSlot()
		else
			print("[InventoryManager]: Slots full!")
			return
		end
		
		local HotbarSlot = GetHotbarSlotFromItem(ItemInHotbar)
				
		-- If the inventory and hotbar is full
		print("TOHB SWAP ITEM")

		InventoryManager.SwapItems("Hotbar", HotbarSlot, InventorySlot)	--pass slots
	else
		print("TOHB MOVING ITEM")
		InventoryManager.MoveItem("Hotbar", ItemInHotbar)
		
	end
end

function InventoryManager.MoveSelectedItemToInventory(ItemInInventory)
	if Values.InventoryOpen == false then print("NotInInv") return end
	local InventorySlot
	if GetTotalInventorySlots() < MAX_SLOTS then
		InventorySlot = AddBlankSlot()
	else
		print("[InventoryManager]: Slots full!")
		return
	end

	if not InventorySlot then
		local HotbarSlot = GetHotbarSlotFromItem()

		if not InventorySlot then print("[InventoryManager]: Could not find the item in the first slot!") end

		-- If the inventory and hotbar is full
		InventoryManager.SwapItems("Inventory", HotbarSlot, InventorySlot)	--pass slots
	else
		InventoryManager.MoveItem("Inventory", ItemInInventory)

	end
end

function InventoryManager.MoveItem(destination, item: Instance)
	if destination == "Hotbar" then
		
		--Move the item data and Fire the re
		
		-- Gets moved to the free slot. call FindEmpt...()
		-- Name, Image, Quantity fetched from the server for anti cheat purposes
				
		local EmptySlot = FindEmptySlotInHotbar()
		
		ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("ToHotbar", item)
		
		if not EmptySlot then warn("[InventoryManager]: Did not find an empty slot and did not proceed to SwapItems") return end
		
		print("MOVING ITEM HB", item.Name)
		
		EmptySlot.Data.HasItem.Value = true
		EmptySlot.Data.ItemName.Value = item.Name
		EmptySlot.Data.ItemQuantity.Value = item.Data.Quantity.Value
		
		EmptySlot.ItemDecal.Image = item.Data.ImageId.Value
		EmptySlot.QuantityDisplay.Text = item.Data.Quantity.Value
		
		GetInventorySlotFromItem(item):Destroy()
		
	elseif destination == "Inventory" then

		--Move the item data and Fire the re
		-- Gets moved to the last slot after the taken one.
		-- Name, Image, Quantity fetched from the server for anti cheat purposes
		ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("ToInventory", item)
		

		local EmptySlot 
		
		if GetTotalInventorySlots() < MAX_SLOTS then
			EmptySlot = AddBlankSlot()
		else
			print("[InventoryManager]: Slots full!")
			InventoryManager.SwapItems("Inventory", GetHotbarSlotFromItem(item), GetLastInventorySlot())
			return
		end
		
		if not EmptySlot then warn("[InventoryManager]: Did not find an empty slot in and did not proceed to SwapItems") end

		print("MOVING ITEM INV", item.Name)


		EmptySlot.HasItem.Value = true
		EmptySlot.Name = item.Name
		EmptySlot.ItemDecal.Image = item.Data.ImageId.Value
		EmptySlot.QuantityDisplay.Text = item.Data.Quantity.Value
		
		
		ClearHotbarSlot(GetHotbarSlotFromItem(item))
	end
end



function InventoryManager.SwapItems(destination:string, HotbarSlot:Instance, InventorySlot:Instance) --slot: Hotbar slot2: Inventory
	
		local HotbarItem = GetHotbarItem(HotbarSlot)
		local InventoryItem = GetInventoryItemFromSlot(InventorySlot)
		
		ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("ToHotbar", InventoryItem)
		ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("ToInventory", HotbarItem)

		
		InventorySlot.Name = HotbarItem.Name
		InventorySlot.QuantityDisplay.Text = HotbarItem.Data.Quantity.Value
		InventorySlot.ItemDecal.Image = HotbarItem.Data.ImageId.Value
		
		HotbarSlot.Data.ItemName.Value = InventoryItem.Name
		HotbarSlot.Data.ItemQuantity.Value = InventoryItem.Data.Quantity.Value
		HotbarSlot.Data.HasItem.Value = true
		
		HotbarSlot.ItemDecal.Image = InventoryItem.Data.ImageId.Value
		HotbarSlot.QuantityDisplay.Text = InventoryItem.Data.Quantity.Value
end

local function CheckHotbarSlotLimit()
	for i,slots in pairs(BackpackUI.HotbarFrame:GetChildren()) do
		if slots.Data.HasItem.Value == false then
			return true
		end
	end
	return false
end

local function CheckSlotLimit()
	local Slots = GetTotalInventorySlots()
	if Slots < MAX_SLOTS then
		return true
	else
		return false
	end
end

function InventoryManager.PickupItem()
	--Check mouse.Hit, if it is a tool, then pick it up and fire the InventoryEvent("Pickup", Item)
	local Mouse = Player:GetMouse()
	local Debounce = false
	
	Mouse.Move:Connect(function()
		local OnTarget = false
		if not Mouse.Target then return end
		
		if Mouse.Target.Parent:IsA("Tool") then
			local Tool = Mouse.Target.Parent
			print("Found a tool")
			OnTarget = true
			PlayerGui.ProximityPromptUI.PromptFrame.Visible = true
			PlayerGui.ProximityPromptUI.PromptFrame.Position = UDim2.new(0, Mouse.X-50, 0, Mouse.Y - 5)
			
			UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
				if not Debounce then
					Debounce = true
					if not OnTarget then return end
					if not gameProcessedEvent then

						if not CheckSlotLimit() then
							print("Slots full")
							if CheckHotbarSlotLimit() then
								Tool:SetAttribute("InHotbar", true)
							else
								print("[InventoryManager]: No Free Slots found!")
								return
							end
						end
						
						if input.KeyCode == Enum.KeyCode.F then
							print("F Pressed", Tool)
							ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("Pickup", Tool)
						end
					end	
					task.wait(2)
					Debounce = false
				end
				
			end)
		else
			OnTarget = false
			PlayerGui.ProximityPromptUI.PromptFrame.Visible = false

		end
	end)
end

local function GetItemFromSlot(slot)
	for i,v:ImageButton in ipairs(BackpackUI.BackpackFrame.BackpackSlotFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			v.MouseEnter:Connect(function()
				return v
			end)
		end
	end
end


return InventoryManager