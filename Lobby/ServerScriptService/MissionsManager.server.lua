--[[
    MissionsManager (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--TODO:CANCELMISSION: Once the re is fired, the server sets the mission to abandoned in the profile template for data saving
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ServerStorage = game:GetService("ServerStorage")

local Bindables = script.Parent:WaitForChild("Bindables")

local ProfileManager = require(game:GetService("ServerScriptService"):WaitForChild("PlayerData").DataService.PlayerDataLoader.Manager)

--------------------------------------------------[Start Mission]-------------------------------------------------------

local function SetData(Player, MissionName, PlanetName)
	--add a check if the DataVal are present or not
	if not Player:FindFirstChild("MissionName") or not Player:FindFirstChild("PlanetName") then
		warn("[MissionManager]: Did not find the required Data Instance Values")
		return
	end
	
	Player.MissionName.Value = MissionName
	Player.PlanetName.Value = PlanetName
end

local function ClearData(Player)
	Player.MissionName.Value = ""
	Player.PlanetName.Value = ""
end

local function SetSavedPlayerMissionData(Player, PlayerProfile)
	if not PlayerProfile then warn("[MissionManager]: No profile received to load data!") return end
	local MissionsTable = PlayerProfile.Data.Missions.ShownMissions
	
	for i,v in pairs(MissionsTable) do
		local MissionName = v.MissionName
		Player.Missions:FindFirstChild(MissionName).Completed.Value = v.Completed
		Player.Missions:FindFirstChild(MissionName).PlayerStatus.Value = v.Status
	end
	
	print("[MissionsManager]: Loaded MissionsData into the MissionsFolder!")
end

local function SpawnMissionInstanceValues(Player, PlayerProfile)
	local MissionName = Instance.new("StringValue")
	MissionName.Name = "MissionName"
	MissionName.Parent = Player
	
	local PlanetName = Instance.new("StringValue")
	PlanetName.Name = "PlanetName"
	PlanetName.Parent = Player
	
	local SpaceshipName = Instance.new("StringValue")
	SpaceshipName.Name = "SpaceshipName"
	SpaceshipName.Parent = Player
	
	local MissionsFolder = ServerStorage.Missions:Clone()
	MissionsFolder.Parent = Player
	
	SetSavedPlayerMissionData(Player, PlayerProfile)
end

local function MissionActive()
	for i,v in pairs(ServerStorage.Missions:GetChildren()) do
		if v:IsA("Folder") then
			if v.Active.Value == true then
				return true
			end
		end
	end
	return false
end

local function StartMission(Player, PlayerProfile, Data)

	local Mission = Data[1]
	if not Mission then warn("[MissionManager]: Invalid mission recieved", Mission) return end
	--Checks
	if PlayerProfile.Data.Missions.ShownMissions[Mission].Completed == true then 
		print("[MissionsManager]: Selected mission is already completed!", Mission) 
		return		
	end
	if MissionActive() then
		print("[MissionsManager]: A mission is already active!") 
		return	
	end
	if Player.MissionName.Value ~= "" then
		print("[MissionsManager]: MissionName Value is not blank!", Player.MissionName.Value) 
		return
	end
	
	Player.Missions:FindFirstChild(Mission).Active.Value = true
	print(Player.Missions[Mission].Active.Value)
	SetData(Player, Data[1], Data[2])
end

-----------------------------------------------[Abort Mission]-----------------------------------------------------------

local function AbortMission(Player, Penalty, PlayerProfile)
	
	
	if not Player:FindFirstChild("MissionName") or not Player:FindFirstChild("PlanetName") then
		warn("[MissionManager]: Did not find the required Data Instance Values for Aborting Mission!")
		return
	end
	
	if not PlayerProfile then 
		warn("[MissionManager]: Did not find data profile for ", Player.Name, "|", tostring(PlayerProfile))
		return
	end
	print("[MissionsManager]: Aborting Mission.", Player.MissionName.Value, "Penalty: ", Penalty)
	
	local Mission = Player.MissionName.Value
	
	if Penalty then
		PlayerProfile.Data.Missions.ShownMissions[Mission].Completed = true
		PlayerProfile.Data.Missions.ShownMissions[Mission].Status = "Failed"
		
		Player.MissionName.Value = ""
		Player.PlanetName.Value = ""
	else
		print("no penalty")
		Player.MissionName.Value = ""
		Player.PlanetName.Value = ""
	end
end

game.Players.PlayerAdded:Connect(function(Player)
	print("[MissionsManager]: Waiting for Data Loaded confirmation from DataScript...")
	Bindables.ServerDataLoaded.Event:Wait()
	print("[MissionsManager]: Data is loaded! Got confirmation from DataScript")
	local PlayerProfile = ProfileManager[Player.Name]
	SpawnMissionInstanceValues(Player, PlayerProfile)
end)

RemoteEvents.MissionEvent.OnServerEvent:Connect(function(Player, EventType, Data) --Data: table
	local PlayerProfile = ProfileManager[Player.Name]
	if EventType == "StartMission" then
		--Data[1]: MissionName (string)
		--Data[2]: PlanetName (string)
		
		StartMission(Player, PlayerProfile, Data)
		
	elseif EventType == "AbortMission" then
		--Data[1]: Pentaly (bool)	
		AbortMission(Player, Data[1], PlayerProfile)
	end
end)