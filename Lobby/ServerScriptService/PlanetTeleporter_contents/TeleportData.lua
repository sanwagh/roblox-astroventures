--[[
    TeleportData (ModuleScript)
    Path: ServerScriptService → PlanetTeleporter
    Parent: PlanetTeleporter
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local DataStoreService = game:GetService("DataStoreService")
local TeleportDataStore = DataStoreService:GetDataStore("TeleportDataStoreTesting")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BindableEvent = Instance.new("BindableEvent")
local PlayersLeft = 0

local TeleportData = {}

function TeleportData.Initialize(player)

	TeleportData.SaveData(player)
end

local function IsTeleportingToPlace(player)
	if player.IsTeleporting.Value == true then
		return true
	else
		return false
	end
end

function TeleportData.SaveData(player)
	--Saves the Slot Number and difficulty level of the slot
	-- For ac purposes, save the date and time of teleport and more
	--Time check can also be used to check if the save is old or not

	if not IsTeleportingToPlace(player) then print("[TeleportData]: Player is not teleporting. Not saving teleport data") return end

	local Key = "Data:"..player.UserId

	local Data = {
		["SlotId"] = player.SlotDataFolder.CurrentSlotId.Value,
		["SaveTime"] = os.time(), --If the Time difference between save and load is >30 sec, invalidate the data and reset this store
		["MissionName"] = player.MissionName.Value,
		["PlanetName"] = player.PlanetName.Value,
		["SpaceshipType"] = player.SpaceshipName.Value
	}

	local success, errormessage = pcall(function()
		TeleportDataStore:SetAsync(Key, Data)
	end)

	if success then
		print("[TeleportData]: Saved TeleportData")
		for i,v in pairs(Data) do
			print(i,v)
		end
		ServerScriptService.Values.ReadyForTP.Value = true

	else
		warn("[TeleportData]: Error Occured while saving TeleportData:", errormessage)
	end
end

return TeleportData