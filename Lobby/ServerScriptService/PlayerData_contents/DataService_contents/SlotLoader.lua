--[[
    SlotLoader (ModuleScript)
    Path: ServerScriptService → PlayerData → DataService
    Parent: DataService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local DataStoreService = game:GetService("DataStoreService")
local SlotsDataStore = DataStoreService:GetDataStore("SlotsDataStoreTesting")

local ServerScriptService = game:GetService("ServerScriptService")
local BindablesFolder = ServerScriptService:WaitForChild("Bindables")

local BindableEvent = Instance.new("BindableEvent")
local PlayersLeft = 0

local PlayerDataModule = require(script.Parent.PlayerDataLoader)

local TextService = game:GetService("TextService")

local SlotLoader = {}

function SlotLoader.Initialize(player)
		SlotLoader.CreateData(player)
		task.spawn(SlotLoader.WaitForClientRequest)
		
	game.Players.PlayerRemoving:Connect(function(player:Player)
		BindablesFolder.InventorySave:Fire(player)
		print("[SlotLoader]: Fired Event to save backpack")
		SlotLoader.SaveSlotsData(player)
	end)
end

function SlotLoader.CreateData(player:Player)
	local SlotDataFolder = Instance.new("Folder")
	SlotDataFolder.Name = "SlotDataFolder"
	SlotDataFolder.Parent = player
	
	local CurrentSlot = Instance.new("StringValue") --Stores the SlotNum of the current slot
	CurrentSlot.Name = "CurrentSlotId"
	CurrentSlot.Parent = SlotDataFolder
	
	local TotalSlots = Instance.new("IntValue") -- Once all the slots are loaded, temporarily stores the number of total slots
	TotalSlots.Name = "TotalSlots"
	TotalSlots.Parent = SlotDataFolder
	
	local Slots = Instance.new("Folder") -- Stores the Data of all the slots as children of this folder
	Slots.Name = "Slots"
	Slots.Parent = SlotDataFolder
	
	local IsTeleporting = Instance.new("BoolValue")
	IsTeleporting.Name = "IsTeleporting"
	IsTeleporting.Parent = player
	
	local DataLoaded = Instance.new("BoolValue")
	DataLoaded.Name = "DataLoaded"
	DataLoaded.Parent = player
	
	--Load the data(using datastore), then create the slots then load data into the slot entries
	SlotLoader.LoadDataIntoTable(player)
end

function SlotLoader.LoadDataIntoTable(player:Player)
	local Key = "Data:"..player.UserId
	
	local Data = {}
	
	local success, errormessage = pcall(function()
		Data = SlotsDataStore:GetAsync(Key)
	end)
	
	if Data == nil then print("Data nil. Setting to table.") Data = {} end
	
	if success then
		print("[SlotLoader]: Loaded Data into Data table.")
		SlotLoader.CreateSlotEntries(player, Data)
	else
		warn("[SlotLoader]: Error Occured while loading data into table. ", errormessage)
	end
end

local function GetData(Data):number
	local count = 0
	for i,v in Data do
		count += 1
	end
	return count
end

function SlotLoader.CreateSlotEntries(player:Player, Data) -- TODO Document
	print(Data)
	local DataCount = GetData(Data)
	if DataCount == 0 then
		print("[SlotLoader]: No Data for player. Fired Remote Event", tostring(player.UserId))
		game.ReplicatedStorage.RemoteEvents.DataStoresLoaded:FireClient(player)

		return 
	end
	
	local success, err = pcall(function()
		for i = 1, DataCount, 1 do
			local SlotFolder = Instance.new("Folder")
			SlotFolder.Name = "Slot"..i
			SlotFolder.Parent = player.SlotDataFolder.Slots

			local SlotName = Instance.new("StringValue")
			SlotName.Name = "SlotName"
			SlotName.Parent = SlotFolder

			local SlotId = Instance.new("StringValue")
			SlotId.Name = "SlotId"
			SlotId.Parent = SlotFolder
			SlotId.Value = "Slot"..i

			local SlotSize = Instance.new("IntValue")
			SlotSize.Name = "SlotSize"
			SlotSize.Parent = SlotFolder

			local CreationDate = Instance.new("StringValue")
			CreationDate.Name = "CreationDate"
			CreationDate.Parent = SlotFolder

			local LastLoadDate = Instance.new("StringValue")
			LastLoadDate.Name = "LastLoadDate"
			LastLoadDate.Parent = SlotFolder	

			local Difficulty = Instance.new("StringValue")
			Difficulty.Name = "Difficulty"
			Difficulty.Parent = SlotFolder
		end
	end)
	
	
	print("[SlotLoader]: Created all Slot Values...")
	SlotLoader.LoadDataIntoSlotEntries(player, Data)
end

function SlotLoader.LoadDataIntoSlotEntries(player:Player, Data)
	local suceess, err = pcall(function()
		local Slots = player.SlotDataFolder.Slots
		print("[SlotLoader]: Loading Data into Entries...")
		for i,value in Data do
			local SlotName = Data[i]
			local slot = Slots[SlotName["SlotId"]]

			slot.CreationDate.Value = value.CreationDate
			slot.LastLoadDate.Value = value.LastLoadDate
			slot.SlotName.Value = value.SlotName
			slot.SlotSize.Value = value.SlotSize
			slot.SlotId.Value = value.SlotId
			slot.Difficulty.Value = value.Difficulty
		end
		PlayersLeft += 1
		game.ReplicatedStorage.RemoteEvents.DataStoresLoaded:FireClient(player)
		
		player.DataLoaded.Value = true
	end)
	if err then
		warn(err)
	end
end

function SlotLoader.SaveSlotsData(player:Player)
	-- do this before Loading data into the values. Create an empty table for each slot Data. Data[v.Name] = {} (v.Name will be added auto)
	
	if player:WaitForChild("DataLoaded").Value == false then 
		warn("[SlotLoader]: Data was not loaded. Aborting save", player.Name)
		return
	end
	
	local Key = "Data:"..player.UserId
	local Data = {}
	
	for i,slot in player.SlotDataFolder.Slots:GetChildren() do
		if slot:IsA("Folder") then
			Data[slot.Name] = {}
			
			Data[slot.Name].SlotName = slot.SlotName.Value
			Data[slot.Name].SlotId = slot.SlotId.Value
			Data[slot.Name].SlotSize = slot.SlotSize.Value
			Data[slot.Name].CreationDate = slot.CreationDate.Value
			Data[slot.Name].LastLoadDate = slot.LastLoadDate.Value
			Data[slot.Name].Difficulty = slot.Difficulty.Value
		end
	end	
	
	local success, errormessage = pcall(function()
		SlotsDataStore:SetAsync(Key, Data)
	end)
	
	if success then 
		print(Data)
		BindableEvent:Fire()
	else
		warn("[SlotLoader]: Error while saving data ", errormessage)
	end
	
	PlayersLeft -= 1
end


function SlotLoader.WaitForClientRequest()
	--Load the slot[CALL THE PROFILESERVICE SCRIPT]
	game.ReplicatedStorage:WaitForChild("RemoteEvents").SlotChangeRequest.OnServerEvent:Connect(function(player,Request, SlotId, Data)
		if Request == "Load" then
			print("[SlotLoader]: Player:", player.Name,"requesting to load", SlotId)
			SlotLoader.LoadSlot(player, SlotId)
		elseif Request == "Name"  then
			print("[SlotLoader]: Player:", player.Name,"requesting to edit name for", SlotId, "to", Data)
			
			if not Data then warn("[SlotLoader]: Invalid Name(slot name) recieved from player ", player.UserId) return end
			
			SlotLoader.EditSlot(player, SlotId, Data)
			
		elseif Request == "Delete" then
			print("[SlotLoader]: Player:", player.Name,"requesting to delete", SlotId)
			
			if not SlotId then warn("[SlotLoader]: Illegal SlotId recieved", SlotId) end
			
			SlotLoader.DeleteSlot(player, SlotId)
			
		elseif Request == "Create" then
			print("[SlotLoader]: Player:", player.Name,"requesting to Create Slot")
			SlotLoader.CreateNewSlot(player, SlotId, Data) -- SlotId = SlotName Data = Difficulty
		end
	end)
end

function SlotLoader.LoadSlot(player:Player, SlotId:string)
	player.SlotDataFolder.CurrentSlotId.Value = SlotId
	PlayerDataModule.Initialize(player, SlotId)
end

local function GetTextObject(text, player)
	local TextObject
	
	local success, errormessage = pcall(function()
		TextObject = TextService:FilterStringAsync(text, player.UserId)
	end)
	if success then
		return TextObject
	else
		warn(errormessage)
	end
end

local function GetFilteredMessege(obj:TextFilterResult)
	local FilteredMessage
	
	local success, errormessage = pcall(function()
		FilteredMessage = obj:GetNonChatStringForBroadcastAsync()
	end)
	if success then 
		return FilteredMessage
	else
		warn(errormessage)
	end
end

function SlotLoader.EditSlot(player:Player, SlotId:string, Data)
	--Pass the Data thru moderation
	local TextObject = GetTextObject(Data, player)
	local FilteredText = GetFilteredMessege(TextObject)
	
	print("Moderated: ", FilteredText)
	player.SlotDataFolder.Slots[SlotId].SlotName.Value = FilteredText
end

function SlotLoader.DeleteSlot(player:Player, SlotId:string)
	-- Call a function in PlayerDataLoader which will wipe all the player data from the profilestore allowing reuable keys
	local Slot = player.SlotDataFolder.Slots:FindFirstChild(SlotId)
	if not Slot then warn("[SlotLoader]: No such slot found to delete! ", SlotId) return end
	
	local DataKey = "Data:"..player.UserId..SlotId
	
	PlayerDataModule.WipeData(player, DataKey)
	Slot:Destroy()
end

local function GetTotalSlots(player)
	local Count = 0
	for i, slot in pairs(player.SlotDataFolder.Slots:GetChildren()) do
		if slot:IsA("Folder") then
			Count += 1
		end
	end
	
	return Count
end

local function CreateSlotDataInstances(player, num, sltName, difficulty)
	local success, err = pcall(function()
		local SlotFolder = Instance.new("Folder")
		SlotFolder.Name = "Slot"..num
		SlotFolder.Parent = player.SlotDataFolder.Slots

		local SlotName = Instance.new("StringValue")
		SlotName.Name = "SlotName"
		SlotName.Parent = SlotFolder
		SlotName.Value = tostring(sltName)

		local SlotId = Instance.new("StringValue")
		SlotId.Name = "SlotId"
		SlotId.Parent = SlotFolder
		SlotId.Value = "Slot"..num

		local SlotSize = Instance.new("IntValue")
		SlotSize.Name = "SlotSize"
		SlotSize.Parent = SlotFolder

		local CreationDate = Instance.new("StringValue")
		CreationDate.Name = "CreationDate"
		CreationDate.Parent = SlotFolder
		CreationDate.Value = os.date()

		local LastLoadDate = Instance.new("StringValue")
		LastLoadDate.Name = "LastLoadDate"
		LastLoadDate.Parent = SlotFolder
		LastLoadDate.Value = os.date()

		local Difficulty = Instance.new("StringValue")
		Difficulty.Name = "Difficulty"
		Difficulty.Parent = SlotFolder
		Difficulty.Value = difficulty
	end)
end

function SlotLoader.CreateNewSlot(player:Player, SltName, difficulty)
	--Get the number of slots present currently in the folder. Assign value+1 as slot Id
	local TotalSlots = GetTotalSlots(player)
	local NewSlotId = TotalSlots + 1
	
	local TextObject = GetTextObject(SltName, player)
	local FilteredText = GetFilteredMessege(TextObject)
	
	CreateSlotDataInstances(player, NewSlotId, FilteredText,difficulty)
	print("[SlotLoader]: Created Slot for player", player.Name, "with Id", NewSlotId)
	PlayerDataModule.Initialize(player, "Slot"..NewSlotId)
end

local function SaveAllPlayerData()
	for i,v in game.Players:GetPlayers() do
		SlotLoader.SaveSlotsData(v)
	end
end

game:BindToClose(function()
	SaveAllPlayerData()
	while PlayersLeft > 0 do
		BindableEvent.Event:Wait()
	end
end)

return SlotLoader