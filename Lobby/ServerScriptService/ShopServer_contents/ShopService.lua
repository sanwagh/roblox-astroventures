--[[
    ShopService (ModuleScript)
    Path: ServerScriptService → ShopServer
    Parent: ShopServer
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ItemsFolder = ServerStorage:WaitForChild("Items")

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	self.PlayerProfile = nil
	return self
end

function module:Init()
	self:BindEvents()
end

function module:BindEvents()
	
	--FetchItemData
	RemoteFunctions.FetchItemData.OnServerInvoke = function(player)
		print("[ShopService]: Pushing item folder to client", player.Name)
		return self:PushItemsFolderToClient()
	end

	-- BuyItems
	RemoteFunctions.BuyItems.OnServerInvoke = function(player, Items, Prices, Quantity) -- Player. Table
		print("[ShopService]: Received a request to approve purchase from", player.Name)

		local Status, Message =  self:ApproveBuyRequest(player, Items, Prices, Quantity)
		
		print("RETURNING", tostring(Status), tostring(Message))
		return Status, Message
	end
	
	--ChangeItemStoreLoc
	RemoteFunctions.ChangeItemStorageLoc.OnServerInvoke = function(player, Item:string)
		if not Item or Item == "" then return false, "No Item Recieved!" end
		
		return self:ChangeItemStorageLoc(player, Item)
	end
end

local function DecompileItemsData(Folder)
	local Items = {}
	for i, tool in pairs(Folder:GetChildren()) do
		if tool:IsA("Tool") then
			Items[tool.Name] = {}
			Items[tool.Name]["Data"] = {}
			Items[tool.Name]["Data"]["Name"] = tool.Name

			for _, data in pairs(tool.Data:GetChildren()) do
				Items[tool.Name]["Data"][data.Name] = data.Value
			end
			Items[tool.Name]["Price"] = tool.PriceValues.Price.Value
		end
	end

	print("ITEMS FOLDER", Items)
	return Items
end

function module:PushItemsFolderToClient()
	return DecompileItemsData(ItemsFolder.Tools)

end

local function ItemsValid(Items)
	for i, tool in pairs(Items) do
		if ItemsFolder.Tools:FindFirstChild(tostring(tool["Name"])) then
			
		else
			return false, tool.Name.." not found."
		end
	end
	return true, "Found!"
end

local function GetItemsPriceTotal(Items)
	local Total = 0
	for i, tool in pairs(Items) do
		local Quantity = tool["Quantity"]
		if not Quantity or  typeof(Quantity) ~= "IntValue" or Quantity <= 0 then
			warn("[ShopService]: WARNING: Quantity of item", tostring(tool), "was not an integer or was negative.", tostring(Quantity), typeof(Quantity))
			
			return
		end
		
		Total += (ItemsFolder.Tools:FindFirstChild(tostring(tool["Name"])).PriceValues.Price.Value * Quantity)
	end
	return Total
end



function module:ApproveBuyRequest(player, Items, Prices, Quantity)
	self.PlayerProfile = require(ServerScriptService.PlayerData.DataService.PlayerDataLoader.Manager)
	
	local Status, Message = ItemsValid(Items)
	local ServerCalcPrice = GetItemsPriceTotal(Items)

	-- Check 2
	if Status == true then
		--Check price and then add to players backpack
		-- Check 2.1
		if self.PlayerProfile[player.Name].Data.Cash >= ServerCalcPrice then
			self.PlayerProfile[player.Name].Data.Cash -= ServerCalcPrice
			
			print("Adding items to backpack")
			self:AddItemsToBackpack(player, Items)
			print("Added items to backpack")
			
			--ServerScriptService.Bindables.InventorySave:Fire(player)
			
			--print("[ShopService]: Sent message to server to update inventory for", player.Name)
			print(self.PlayerProfile[player.Name].Data.Cash)
			
			return true, "Success"
		else
			print(self.PlayerProfile[player.Name].Data.Cash)

			return false, "Not Enough Money"
		end		

	else
		warn("[ShopService]: ", Message)

		return false, "Tool not present"
	end
end

function module:AddItemsToBackpack(player, Items)
	for i, tool in pairs(Items) do
		if ItemsFolder.Tools:FindFirstChild(tostring(tool["Name"])) then
			print("Updated Tool Quantity")
			if player.Backpack:FindFirstChild((tostring(tool["Name"]))) then
				player.Backpack:FindFirstChild((tostring(tool["Name"]))).Data.Quantity.Value += 1
			else
				print("Added new tool")
				local clone = ItemsFolder.Tools:FindFirstChild(tostring(tool["Name"])):Clone()
				clone.Parent = player.Backpack
			end
			
		else
			warn("[ShopService]: Item Not found!", tool["Name"])
		end
	end
end

function module:ChangeItemStorageLoc(player, Item:string)
	if not Item or not player then 
		print("[ShopService]: Did not recieve player or item!", player, Item) 
		return false, "An Error occured. Please try again."
	end
	
	local ItemInBackpack = player.Backpack:FindFirstChild(Item)
	
	if not ItemInBackpack then warn("[ShopService]: Requested Item not located! Unable to change loc")
		return "An Error occured while searching for the item. Please Try again."
	end
	
	local InStorageVal = ItemInBackpack.Data.InStorage
	
	print(InStorageVal.Value)
	InStorageVal.Value = not InStorageVal.Value
	
	print("[ShopService]: Changed Storage Value to", InStorageVal.Value)
	
	local Message = ""
	if InStorageVal.Value == true then 
		Message = "Storage"
	else
		Message = "Inventory"
	end
	
	return true, Message
end

return module
