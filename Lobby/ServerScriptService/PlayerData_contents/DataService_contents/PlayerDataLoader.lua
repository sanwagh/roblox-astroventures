--[[
    PlayerDataLoader (ModuleScript)
    Path: ServerScriptService → PlayerData → DataService
    Parent: DataService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local ProfileStoreName = "StudioPreTest"
--[[{Names Used:
			StudioPreTest: Pre-release Testing			
			
	}
]]

local Players = game:GetService("Players")

local ProfileServiceModule = require(script.ProfileService)
local ProfilesManager = require(script.Manager)
local DataTemplate = require(script.DataTemplate)

local ProfileStore = ProfileServiceModule.GetProfileStore(ProfileStoreName, DataTemplate)

local PlayerDataLoader = {}

function PlayerDataLoader.Initialize(player:Player, SlotId: string)
	-- Once this function is called, load the profile store not on player added
	-- Check if the ProfileStoreName is Produciton or not.
	print("[PlayerDataLoader]: LoadingProfile")
	
	player.PlayerGui.Info.LoadingFrame.Visible = true

	
	
	PlayerDataLoader.LoadPlayerProfile(player, SlotId)
	player.SlotDataFolder.Slots:FindFirstChild(SlotId).LastLoadDate.Value = os.date()
end

function PlayerDataLoader.LoadPlayerProfile(player:Player, SlotId)
	print("SlotId Type recieved: ", type(SlotId))
	if SlotId == nil or SlotId == "" or not SlotId then
		warn()
	end
	
	local Key = "Data:"..player.UserId..SlotId
	
	local Profile = ProfileStore:LoadProfileAsync(Key)
	
	if Profile ~= nil then
		Profile:AddUserId(player.UserId)
		Profile:Reconcile()
		
		Profile:ListenToRelease(function()
			ProfilesManager[player.Name] = nil
			player:Kick("ERR: Profile may be loaded on a different server")
		end)
		
		if player:IsDescendantOf(Players) == true then
			ProfilesManager[player.Name] = Profile
			print("[PlayerDataLoader]: Loaded Profile for", player.Name," with key", Key)
			PlayerDataLoader.OnProfileLoaded(player, Profile)	
			
		else
			Profile:Release()
		end
	else
		player:Kick("ERR: Could not load profile as another server was loading it.")
	end
end

function PlayerDataLoader.WipeData(player, ProfileKey)
	ProfileStore:WipeProfileAsync(ProfileKey)
	warn("[PlayerDataLoader]: Succesfully wiped data for key", ProfileKey)
end


function PlayerDataLoader.OnProfileLoaded(player, Profile)
	print("[PlayerDataLoader]: Loaded Profile", player.Name, Profile)
	
	
	player.PlayerGui.Info.LoadingFrame.LoadingBarFrame.Title.Text = "Success!"
	task.wait(0.5)
	player.PlayerGui.Info.LoadingFrame.Visible = false
	
	Profile.Data.LogInTimes += 1
	Profile.Data.LastLoaded = os.date() --There will be a slight delay in timestamps displayed and the actual load ones
	print("Time taken to load: "..time().." seconds.")	
	
	PlayerDataLoader.ManageUI(player)
	PlayerDataLoader.LoadProfileData(player, Profile)
	PlayerDataLoader.UpdateBackpackSaves(player, Profile)
	
	game.ServerScriptService.Bindables.ServerDataLoaded:Fire()
	print(Profile)
end

function PlayerDataLoader.ManageUI(Player)
	Player.PlayerGui.BackpackUI.HotbarFrame.Visible = true
end
----------------------------------------------------[LOAD FUNCTIONS]-------------------------------------------------------

function PlayerDataLoader.LoadProfileData(Player,Profile)
	print("[PlayerDataLoader]: Loading Player Backpack...")
	PlayerDataLoader.LoadPlayerBackpack(Player, Profile)
	PlayerDataLoader.UpdateProfileSaves(Player, Profile)
	PlayerDataLoader.AddCash(Player, Profile)	
end

function PlayerDataLoader.AddCash(Player, Profile)
	
	if Profile.Data.Cash == 0  then
		warn("[PlayerDataLoader]: WARNING!!: ADDING CASH TO PLAYER", Player.Name)

		Profile.Data.Cash += 500
		warn("[PlayerDataLoader]: WARNING!!: ADDED CASH TO PLAYER", Player.Name, Profile.Data.Cash)
	end
	
end

local function GetToolFromItems(toolName) : Tool
	for i,v in pairs(game.ServerStorage.Items:GetDescendants()) do
		if v:IsA("Tool") and v.Name == toolName then
			return v
		end
	end
end

function PlayerDataLoader.LoadPlayerBackpack(Player, Profile)
	local ItemsFolder = game.ServerStorage.Items

	local BackpackTable = Profile.Data.Backpack
	local InventoryTable = BackpackTable.Inventory
	local HotbarTable = BackpackTable.Hotbar

	for i,data in pairs(InventoryTable) do
		if data.ToolName ~= nil then
			local Tool = GetToolFromItems(data.ToolName)
			
			if Tool then
				
				if Player.Backpack:FindFirstChild(Tool.Name) then warn("[PlayerDataLoader]: Tool Duplicate Detected: Inventory") end
				
				local NewTool = Tool:Clone()
				NewTool.Parent = Player.Backpack
				NewTool.Data.Quantity.Value = data.Quantity
				NewTool.Data.InStorage.Value = data.StoredLoc
			end
		end
	end
	
	for i,data in pairs(HotbarTable) do
		if data.ToolName ~= nil then
			local Tool = GetToolFromItems(data.ToolName)

			if Tool then
				if Player.Backpack:FindFirstChild(Tool.Name) then warn("[PlayerDataLoader]: Tool Duplicate Detected: Hotbar") end

				local NewTool = Tool:Clone()
				NewTool.Parent = Player.Backpack
				NewTool.Data.Quantity.Value = data.Quantity
				NewTool:SetAttribute("Equipped", true)
				NewTool.Data.InStorage.Value = data.StoredLoc
			end
		end
	end
end
----------------------------------------------------[SAVE FUNCTIONS]-------------------------------------------------------

function PlayerDataLoader.UpdateProfileSaves(Player, Profile)
	task.spawn(function()
		game.ReplicatedStorage.RemoteEvents.InventoryEvent.OnServerEvent:Connect(function(plr, Type)
			if Type == "Update" then
				print("[PlayerDataLoader]: Inventory Updated for player", Player.Name, ". Updating changes in Data table!")
				PlayerDataLoader.UpdateBackpackSaves(Player, Profile)
			end
		end)
	end)
	
	task.spawn(function()
		-- Handled mainly by the PlayerRemoving Event and other scripts to update the inv
		game.ServerScriptService.Bindables.InventorySave.Event:Connect(function(plr)
			warn("SAVE FIRED")
			if plr.Name == Player.Name then 
				print("[PlayerDataLoader]: Inventory Updated for player", Player.Name, ". Updating changes in Data table!")
				PlayerDataLoader.UpdateBackpackSaves(Player, Profile)
			end
			
		end)
	end)
end

function PlayerDataLoader.UpdateBackpackSaves(Player, Profile)
	print("[PlayerDataLoader]: Updating backpack")
	local BackpackTable = Profile.Data.Backpack
	local InventoryTable = BackpackTable.Inventory
	local HotbarTable = BackpackTable.Hotbar
	
	for i,tool in pairs(Player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:GetAttribute("Equipped") == true then
				--Check if the tool is already present
				if HotbarTable[tool.Name] then 
					HotbarTable[tool.Name] = {}
				end
				HotbarTable[tool.Name] = {
					ToolName = tool.Name,
					Quantity = tool.Data.Quantity.Value,
					StoredLoc = tool.Data.InStorage.Value,
				}
			else
				if InventoryTable[tool.Name] then 
					InventoryTable[tool.Name] = {}
				end

				InventoryTable[tool.Name] = {
					ToolName = tool.Name,
					Quantity = tool.Data.Quantity.Value,
					StoredLoc = tool.Data.InStorage.Value
				}
			end
		end
	end
	
	print("Backpack: ",BackpackTable)
end

return PlayerDataLoader