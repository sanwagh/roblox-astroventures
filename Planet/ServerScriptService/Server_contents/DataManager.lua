--[[
    DataManager (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

-- Sets the Missionname, PlanetName, spaceshipname and the slotId for the PlayerDataLoader to load the profile

local DataStoreService = game:GetService("DataStoreService")
local TeleportDataStore = DataStoreService:GetDataStore("TeleportDataStoreTesting")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

--TODO:IMP_HIGH: Check if the game is running in studio. if yes, ignore the teleport data

local Values = ServerScriptService.Server.Values
local PlayerDataLoader = require(script.PlayerDataLoader)

local DataManager = {}
DataManager.__index = DataManager

function DataManager.new()
	local self = setmetatable({}, DataManager)

	self.Player = nil

	return self
end

function DataManager:Init()
	game.Players.PlayerAdded:Connect(function(player)
		self.Player = player

		if not self.Player then warn("No Player found!") return end

		print(self.Player)

		self:CreateData()

		if self:LoadData() then
			PlayerDataLoader.Initialize(player, player.SlotId.Value)
		end
	end)
end

function DataManager:CreateData()
	local SlotId = Instance.new("StringValue")
	SlotId.Name = "SlotId"
	SlotId.Parent = self.Player	

	local PlanetName = Instance.new("StringValue")
	PlanetName.Name = "PlanetName"
	PlanetName.Parent = self.Player

	local MissionName = Instance.new("StringValue")
	MissionName.Name = "MissionName"
	MissionName.Parent = self.Player

	local SpaceshipName = Instance.new("StringValue")
	SpaceshipName.Name = "SpaceshipName"
	SpaceshipName.Parent = self.Player
	
	if RunService:IsStudio() then
		warn("[DataManager]: Runtime: Studio")
		warn("[DataManager]: Loading Temp Data Values")
		PlanetName.Value = "Planet32B"
		MissionName.Value = "Planet32BBasic"
		SpaceshipName.Value = "StarterShip"


		game.ServerScriptService.ServerEvents.DataLoaded:Fire(self.Player)
		Values.DataLoaded.Value = true
		warn("UPDATED TEMP VAL")
	end
end

local function ValidateData(Data)
	--Check if the time difference is < 25
	if RunService:IsStudio() then print("[DataManager]: Current environment: STUDIO. Setting data as valid") return true end

	--if Data.Teleport == true then 
	--	return true
	--else 
	--	warn("[DataManager]: Player was  not teleporting")
	--	return false
	--end
	return true
end

function DataManager:LoadData()
	local Key = "Data:"..self.Player.UserId

	local Data

	local success, errormessage = pcall(function()
		Data = TeleportDataStore:GetAsync(Key)
	end)

	if success then
		if ValidateData(Data) then
			-- Added as a pcall to prevent the script from terminating incase of any error
			local success, err = pcall(function()
				self.Player.SlotId.Value = Data.SlotId
				self.Player.MissionName.Value = Data.MissionName
				self.Player.PlanetName.Value = Data.PlanetName
				self.Player.SpaceshipName.Value = Data.SpaceshipType
			end)
			if err then
				warn("[DataManager]: Error while setting data,", err) 
			else
				print("[DataManager]: Success in setting data!") 
				for i,v in pairs(Data) do
					print(i,v)
				end
				warn("DataManager"..self.Player.MissionName.Value, self.Player.PlanetName.Value)
			end

		else
			print("Warn the player and abort loading")

			return nil
		end

	else
		warn("[DataManager]: Error Occured while loading data!", errormessage)
		return nil
	end
	self:ClearData()
	return true
end

function DataManager:ClearData()
	local Key = "Data:"..self.Player.UserId

	TeleportDataStore:RemoveAsync(Key)
end

return DataManager