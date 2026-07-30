--[[
    ShopUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → ShopUIClient
    Parent: ShopUIClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gui = ReplicatedStorage:WaitForChild("Gui")

--TODO: Test, make sure all funcs are called 
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
	self.DisplayTitle = self.ShopFrame.MainFrame.DisplayTitle
	self.OwnedItemsFrame = self.ShopFrame.MainFrame.OwnedItemsFrame
	self.CloseBtn = self.ShopFrame.CloseBtn
	self.ErrorLabel = self.ShopFrame.ErrorLabel

	self.ItemsFolder = nil

	self.DefaultItemsShopFrame = 0
	
	-- Modules
	self.OwnedItemsModule = require(script.Parent.OwnedItemsUI).new()

	self.FETCH_ITEM_DATA_CONNECTION = nil
	self.ATC_BTN_CONNECTION = nil
	self.OWNED_ITEMS_BTN_CONNECTION = nil

	return self
end

function module:Init()
	task.spawn(function()
		self:BindEvents()
	end)
	
	self:GetItemData() 
	self:WaitForAddToCartClick()
	self.OwnedItemsModule:Init()
end

function module:BindEvents()
	-- All the button events are here
	self.CloseBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self:CloseUI()
	end)

	--Buy Btn
	self.CartFrame.ButtonFrame.BuyBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self:BuyCart()
	end)

	--ClearCart Btn
	self.CartFrame.ButtonFrame.ClearBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self:ClearCart()
	end)

	-- Shop Btn
	self.ShopFrame.MainFrame.ButtonFrame.ShopBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self:DisplayShopComponent()
	end)

	--OwnedItems Btn
	
	self.ShopFrame.MainFrame.ButtonFrame.OwnedItemsBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		self.OwnedItemsModule:ShowUI()
	end)
end

function module:OpenShopUI() --Called by the ShopHandler
	self.ShopFrame.Visible = true
end

function module:DisplayShopComponent()
	self.ItemsFrame.Visible = true
	self.CartFrame.Visible = true
	
	self.OwnedItemsFrame.Visible = false
end

--function module:DisplayOwnedItemsComponent()
--	self.ItemsFrame.Visible = false
--	self.CartFrame.Visible = false

--	self.OwnedItemsFrame.Visible = true
--end

function module:GetItemData() --Load ItemFrames with item details
	print("[ShopUI]: Requesting Server for Item Data. Fetching....")
	self.ItemsFolder = ReplicatedStorage.RemoteFunctions.FetchItemData:InvokeServer()

	if not self.ItemsFolder then warn("[ShopUI]: Server returned nil.", self.ItemsFolder) return end
	print("[ShopUI]: Received Items Data from server.")

	self:LoadShopItemFrames()
end

--Loads the data of items into the frames for the shop
function module:LoadShopItemFrames()
	self.DefaultItemsShopFrame = #self.ItemsFrame.ShopFrame:GetChildren()
	print("Default items: ", self.DefaultItemsShopFrame)
	for i,item in pairs(self.ItemsFolder) do
		local ToolFrameClone = Gui.ToolFrame:Clone()
		
		warn(item)
		ToolFrameClone.Name = item.Data["Name"] --Frame name used further to fetch item for cart update.
		ToolFrameClone.ItemName.Text = item.Data["DisplayName"]
		ToolFrameClone.ItemDesc.Text = item.Data["Desc"]
		ToolFrameClone.Parent = self.ItemsFrame.ShopFrame
	end
end

function module:WaitForAddToCartClick()
	if #self.ItemsFrame.ShopFrame:GetChildren() <= self.DefaultItemsShopFrame then return end

	if self.ATC_BTN_CONNECTION then self.ATC_BTN_CONNECTION:Disconnect() end

	for i, frame in pairs(self.ItemsFrame.ShopFrame:GetChildren()) do
		if frame:IsA("Frame") then
			self.ATC_BTN_CONNECTION = frame.AddToCartBtn.MouseButton1Down:Connect(function()
				game.SoundService.SFX.SecondaryClick:Play()
				frame.AddToCartBtn.Visible = false
				self:AddItemToCart(frame.Name)
			end)
		end
	end
end

function UpdateItemCostValues(CartFrame)
	local ItemCostDisplay = CartFrame.ItemCostDisplay
	local CostValues = ItemCostDisplay.CostValues

	ItemCostDisplay.TotalPriceDisplay.Text = "$"..tostring(CostValues.TotalPrice.Value)
	ItemCostDisplay.TaxesDisplay.Text = "-$"..tostring(CostValues.Tax.Value)
	ItemCostDisplay.FinalAmountDisplay.Text = "$"..tostring(CostValues.FinalAmount.Value)
	print("Updated cart costs")
end

local function UpdateQuantityDisplay(frame)
	if not frame then return end
	frame.QuantityFrame.QuantityDisplay.Text = ""..tostring(frame.Quantity.Value)
end

local function ChangeQuantity(frame, self)
	if not frame then return end
	
	
	-- Add
	frame.QuantityFrame.Add.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		
		frame.Quantity.Value += 1
		UpdateQuantityDisplay(frame)
		--TODO update prices here

		UpdateItemCostValues(self.CartFrame)
	end)
	
	-- Subtract
	frame.QuantityFrame.Subtract.MouseButton1Down:Connect(function()
		if frame.Quantity.Value <= 1 then 
			self:RemoveItemFromCart(frame, self)
			return
		end
		game.SoundService.SFX.SecondaryClick:Play()

		frame.Quantity.Value -= 1
		UpdateQuantityDisplay(frame)
		
		--TODO update prices here
		UpdateItemCostValues(self.CartFrame)
	end)
end

function module:AddItemToCart(item:string)
	local Item = self.ItemsFolder[item]

	if not Item then warn("[ShopUI]: Item not found! ", Item, item) return end

	local CartItemClone = ReplicatedStorage.Gui.CartItemFrame:Clone()
	CartItemClone.Name = Item.Data.Name --Used later on to fetch item to update cart price
	CartItemClone.ItemName.Text = Item.Data.DisplayName
	CartItemClone.Parent = self.CartFrame.CartDisplay

	--Update Prices
	local ItemCostDisplay = self.CartFrame.ItemCostDisplay	
	local CostValuesFolder = ItemCostDisplay.CostValues

	local Tax = math.round(0.1*Item["Price"])

	CostValuesFolder.TotalPrice.Value += Item["Price"] - Tax
	CostValuesFolder.Tax.Value += Tax
	CostValuesFolder.FinalAmount.Value += Item["Price"]

	UpdateItemCostValues(self.CartFrame)
	ChangeQuantity(CartItemClone)
end

function module:RemoveItemFromCart(frame)
	local Item = self.ItemsFolder[frame.Name]
	if not Item then warn("[ShopUI]: Item not found to remove!", tostring(Item)) return end
	
	frame:Destroy()
	local CostValuesFolder = self.CartFrame.ItemCostDisplay.CostValues
	local Tax = math.round(0.1*Item["Price"])

	CostValuesFolder.TotalPrice.Value += Item["Price"] - Tax
	CostValuesFolder.Tax.Value += Tax
	CostValuesFolder.FinalAmount.Value += Item["Price"]
	UpdateItemCostValues(self.CartFrame)
	
	self.ItemsFrame.ShopFrame:FindFirstChild(frame.Name).AddToCartBtn.Visible = true
end

local function GetCartInstances(Cart)
	local FramesInCart = 0
	for i,v in pairs(Cart) do
		FramesInCart += 1
	end

	return FramesInCart
end

function module:BuyCart()
	local Items = {} -- Passed on to the server for validation and buying

	if #self.CartFrame.CartDisplay:GetChildren() <= 1 then
		return
	end

	for i, frame in pairs(self.CartFrame.CartDisplay:GetChildren()) do
		if frame:IsA("Frame") then

			if not self.ItemsFolder[frame.Name] then
				warn("[ShopUI]: Item not found while buying.", frame.Name)
				continue
			end

			Items[frame.Name] = {}
			Items[frame.Name]["Name"] = frame.Name
			Items[frame.Name]["Quantity"] = frame.Quantity.Value
		end
	end

	if GetCartInstances(Items) == 0 then warn("[ShopUI]: Cart is empty") return end

	print("[ShopUI]: Sent a request to purchase...")
	
	local FinalPrice = self.CartFrame.ItemCostDisplay.CostValues.FinalAmount.Value
	local Status, Message = ReplicatedStorage.RemoteFunctions.BuyItems:InvokeServer(Items, FinalPrice)

	if Status == true then
		self:ClearCart()

		Items = {}
		print("[ShopUI]: Purchase Success")
	else
		-- Error will be displayed on a TextLabel.
		self.ErrorLabel.Visible = true
		self.ErrorLabel.Text = "Error: "..tostring(Message)
		task.wait(2)
		self.ErrorLabel.Visible = false
	end
end

function module:ClearCart()
	for i, frame in pairs(self.CartFrame.CartDisplay:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
	
	-- Clear Price vals stored in IntValues
	for i, val in pairs(self.CartFrame.ItemCostDisplay.CostValues:GetChildren()) do
		if val:IsA("IntValue") then
			val.Value = 0
		else
			warn("[ShopUI]: ", tostring(val),"is not an integer val. Type", typeof(val))
		end
	end
	
	--Clear the Price in UI. Function fetches price values from the folder which is already reset.
	UpdateItemCostValues(self.CartFrame)
	
	-- Set Add to cart btn to visible
	for i, frame in pairs(self.ItemsFrame.ShopFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.AddToCartBtn.Visible = true
		end
	end
end

function module:CloseUI()
	game.SoundService.SFX.SecondaryClick:Play()
	self.ShopFrame.Visible = false
end

return module
