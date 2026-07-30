--[[
    PlayerDataLoader (ModuleScript)
    Path: ServerScriptService → Server → DataManager
    Parent: DataManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ProfileStoreName = "StudioPreTest"
--[[{Names Used:
			StudioPreTest: Pre-release Testing			
			
	}
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileServiceModule = require(script.ProfileService)
local ProfilesManager = require(script.Manager)
local DataTemplate = require(script.DataTemplate)
local Values = ServerScriptService.Server.Values

local ProfileStore = ProfileServiceModule.GetProfileStore(ProfileStoreName, DataTemplate)

local PlayerDataLoader = {}

function PlayerDataLoader.Initialize(player:Player, SlotId: string)
	-- Once this function is called, load the profile store not on player added
	-- Check if the ProfileStoreName is Produciton or not.
	print("[PlayerDataLoader]: LoadingProfile")
	
	--player.PlayerGui.Info.LoadingFrame.Visible = true
	
	PlayerDataLoader.LoadPlayerProfile(player, SlotId)
end

function PlayerDataLoader.LoadPlayerProfile(player:Player, SlotId)
	print("SlotId Type recieved: ", type(SlotId))
	if SlotId == nil or SlotId == "" or not SlotId then
		warn("[PlayerDataLoader]: Slot not found!", SlotId)
		return
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
	
	
	Profile.Data.LogInTimes += 1
	Profile.Data.LastLoaded = os.date() --There will be a slight delay in timestamps displayed and the actual load ones
	print("Time taken to load: "..time().." seconds.")	
	
	PlayerDataLoader.ManageUI(player)
	PlayerDataLoader.LoadProfileData(player, Profile)
	PlayerDataLoader.UpdateBackpackSaves(player, Profile)
	
	game.ServerScriptService.ServerEvents.DataLoaded:Fire(player) -- SERVER EVENT
	game.ReplicatedStorage.RemoteEvents.DataLoaded:FireClient(player) -- client event
	
	Values.DataLoaded.Value = true
	print(Profile)
end

function PlayerDataLoader.ManageUI(Player)
	task.wait(20)
	warn("[PlanetDataLoader]: A STATIC WAIT OF 20 SECONDS IS ADDED")
	Player.PlayerGui.BackpackUI.HotbarFrame.Visible = true
end
----------------------------------------------------[LOAD FUNCTIONS]-------------------------------------------------------

function PlayerDataLoader.LoadProfileData(Player,Profile)
	print("[PlayerDataLoader]: Loading Player Backpack...")
	
	--Player.PlanetName.Value = Profile.Data.TeleportData.PlanetName
	--Player.MissionName.Value = Profile.Data.TeleportData.MissionName
	
	PlayerDataLoader.LoadPlayerBackpack(Player, Profile)
	PlayerDataLoader.UpdateProfileSaves(Player, Profile)
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
				local NewTool = Tool:Clone()
				NewTool.Parent = Player.Backpack
				NewTool.Data.Quantity.Value = data.Quantity
			end
		end
	end
	
	for i,data in pairs(HotbarTable) do
		if data.ToolName ~= nil then
			local Tool = GetToolFromItems(data.ToolName)

			if Tool then
				local NewTool = Tool:Clone()
				NewTool.Parent = Player.Backpack
				NewTool.Data.Quantity.Value = data.Quantity
				NewTool:SetAttribute("Equipped", true)
			end
		end
	end
end
----------------------------------------------------[SAVE FUNCTIONS]-------------------------------------------------------

function PlayerDataLoader.UpdateProfileSaves(Player, Profile)
	task.spawn(function()
		game.ReplicatedStorage.RemoteEvents.InventoryEvent.OnServerEvent:Connect(function()
			print("[PlayerDataLoader]: Inventory Updated for player", Player.Name, ". Updating changes in Data table!")
			PlayerDataLoader.UpdateBackpackSaves(Player, Profile)
		end)
	end)
end

function PlayerDataLoader.UpdateBackpackSaves(Player, Profile)
	local BackpackTable = Profile.Data.Backpack
	local InventoryTable = BackpackTable.Inventory
	local HotbarTable = BackpackTable.Hotbar
	
	for i,tool in pairs(Player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:GetAttribute("Equipped") == true then
				HotbarTable[tool.Name] = {
					ToolName = tool.Name,
					Quantity = tool.Data.Quantity.Value,
				}
			else
				InventoryTable[tool.Name] = {
					ToolName = tool.Name,
					Quantity = tool.Data.Quantity.Value,
				}
			end
		end
	end
end

function PlayerDataLoader.UpdateTeleportData(Player, Profile) --TODO: Move this to missionsManager after revamp
	local TeleportData = Profile.Data.TeleportData
	
	TeleportData.PlanetName = ""
	TeleportData.MissionName = ""
	TeleportData.Teleport = false
	
	--Main Place Code
	--Player.MissionName:GetPropertyChangedSignal("Value"):Connect(function()
	--	TeleportData.PlanetName = Player.PlanetName.Value
	--	TeleportData.MissionName = Player.MissionName.Value
		
	--	print("Set Spaceship type as well")
	--	print("Transfer func later!")
	--end)
end

return PlayerDataLoader