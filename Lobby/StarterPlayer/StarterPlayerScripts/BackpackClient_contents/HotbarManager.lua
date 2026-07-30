--[[
    HotbarManager (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → BackpackClient
    Parent: BackpackClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player:Player = game.Players.LocalPlayer

local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGear = Player:WaitForChild("Backpack")
print("STARTERGEAR IS BACKPACK AS OF NOW")
local UserInputService = game:GetService("UserInputService")

local BackpackUI = PlayerGui:WaitForChild("BackpackUI")
local HotbarFrame = BackpackUI:WaitForChild("HotbarFrame")

local Values = require(script.Parent.Parent.Values)

local HotbarManager = {}

local EnumKeys = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
}

function HotbarManager.LoadHotbarOnStart()
	--while #StarterGear:GetChildren() <= 0 do
	--	task.wait()
	--end
	
	local PrevSlot = nil -- This is to prevent item visual duplication in the next slot of the hotbar.
	
	for i,item in pairs(StarterGear:GetChildren()) do
		if item:GetAttribute("InHotbar") == true then
			for _, slot in pairs(HotbarFrame:GetChildren()) do
				if slot:IsA("ImageButton")  then
					if slot.Data.HasItem.Value == false then
						if PrevSlot then 
							if PrevSlot.Data.ItemName.Value == item.Name then
								warn("TEST DEBUG: Item Already loaded in previous slot!", PrevSlot, item.Name)
								continue
							end
						end
						
						print("HAS ITEM PART RUN")
						slot.Data.HasItem.Value = true

						slot.Data.ItemName.Value = item.Name
						slot.Data.ItemQuantity.Value = item.Data.Quantity.Value
						slot.ItemDecal.Image = item.Data.ImageId.Value
						break
					end
					PrevSlot = slot
				end
			end
			
		end
		if i > 3 then
			warn("[HotbarManager]: Exceeded the hotbar limit. THIS IS A MAJOR BUG|", Player.Name)
		end
	end
end

local function ClearHotbarSlot(slot)
	slot.Data.HasItem.Value = false
	slot.Data.ItemName.Value = ""
	slot.Data.ItemQuantity.Value = 0
	slot.ItemDecal.Image = ""
	slot.QuantityDisplay.Text = ""
end

function HotbarManager.UpdateSlotValues()
	for i,v in pairs(HotbarFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			if v.Data.HasItem.Value == true then
				local Item = StarterGear:FindFirstChild(v.Data.ItemName.Value)
				if Item.Data.Quantity.Value <= 0 then
					ClearHotbarSlot(v)
				else
					v.QuantityDisplay.Text = Item.Data.Quantity.Value
				end
			else
				v.QuantityDisplay.Text = ""
			end
		end
	end
end

local function GetSlotFromItem(item)
	for i,v in pairs(HotbarFrame:GetChildren()) do
		if v:IsA("ImageButton") then
			if v.Data.ItemName.Value == item.Name then
				return v
			end
		end
	end
end

local function GetItemFromSlot(slot)
	
	if Player.Character.EquippedItem.Value == nil or Player.Character.EquippedItem.Value == "" then
		return StarterGear:FindFirstChild(slot.Data.ItemName.Value)
	else
		return Player.Character:FindFirstChild(Player.Character.EquippedItem.Value)
	end
end

local function GetEquippedItem()
	for i, item in pairs(Player.Character:GetChildren()) do
		if item:GetAttribute("Equipped") == true then
			return item
		end
	end	
end


function HotbarManager.DropItem() 
	-- Press q on the hovering item and it drops. Else drops the eqipped one

	--Whenever Q is clicked, it checks for an equipped item. If none, then check if the mouse is hovering over any. If none, do nthg
	--Priority: Equipped > MouseHovering

	--Check for equipped item or if inventory is open(check values module), the hover

	print("Called Drop Item")
	local EquippedItem = GetEquippedItem()

	if not EquippedItem then warn("[InventoryManager]: No Equipped Item to drop!") return end

	ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("Drop", EquippedItem)
	
	local Slot = GetSlotFromItem(EquippedItem)
	Player.Character.EquippedItem.Value = ""
	--  Add a thing later on where if q is pressed for a long time, the drop rate increases exponentially

	-- v add this block in the future.
--[[
if Values.InventoryOpen == true then
		--local Item = GetItemFromSlot() --TODO Pass in the slot: LATER
	else
		
	end
]]	

ClearHotbarSlot(Slot)

end

local function IsStoreable(item)
	if item:GetAttribute("Storage") == true then
		return true
	else
		return false
	end
end

local function IsNearStorage()
	for i,storage in pairs(game.Workspace.Utilities.StorageUnits:GetChildren()) do
		if (storage.PrimaryPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 10 then
			return true
		else
			return false
		end
	end
end

------------------------------------------- OBSOLETE!!!!
function HotbarManager.StoreItem(item)
	-- On prompt Trigger, stores it in the storage and saves it in to the main data

	if IsStoreable(item) and IsNearStorage() then
		ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("Store", item)
		print("Storing Item called")
		ClearHotbarSlot(GetSlotFromItem(item))
		print("Cleared the slot")
	end
end

function HotbarManager.EquipOnKeyPress()
	--UIS, key press, check EnumValues, if an input, then get key and key is the inventory slot. unequip all and Equip the current
	if Values.InventoryUISConnection then Values.InventoryUISConnection:Disconnect() end
	
	Values.InventoryUISConnection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.One then
				HotbarManager.EquipItem(HotbarFrame.Slot1)
				
			elseif input.KeyCode == Enum.KeyCode.Two then
				HotbarManager.EquipItem(HotbarFrame.Slot2)

			elseif input.KeyCode == Enum.KeyCode.Three then
				HotbarManager.EquipItem(HotbarFrame.Slot3)

			end
		end	
	--	if Values.InventoryUISConnection then Values.InventoryUISConnection:Disconnect() end

	end)
end

function HotbarManager.EquipItem(slot)
	if slot.Data.HasItem.Value == false then return end
	print("Equip item", slot)
	local Item = GetItemFromSlot(slot)
	print(Item)
	if not Item then return	end
	
	if Item:GetAttribute("Equipped") == true then print("UEEE", slot, Item) HotbarManager.UnequipItem(slot, Item) return end
	Player.Character.EquippedItem.Value = Item.Name
	
	ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("Equip", Item) --Make sure to unequip all other items from server
	print("Fired Event to Equip Item")

end

function HotbarManager.UnequipItem(slot, item)
	print("Unequip item", slot)
	Player.Character.EquippedItem.Value = "" or nil
	
	ReplicatedStorage.RemoteEvents.InventoryEvent:FireServer("Unequip", item)
	print("Fired Event to Unequip Item")

end

return HotbarManager