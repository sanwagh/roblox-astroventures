--[[
    PlanetTeleporter (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileModule = require(ServerScriptService:WaitForChild("PlayerData").DataService.PlayerDataLoader.Manager)
local TeleportData = require(script.TeleportData)

local ServerID = 140214143174948

local function UpdateSpaceshipData(Player, SpaceshipName)
	if not SpaceshipName then warn("[PlanetTeleporter]: Did not find SpaceshipName: ", tostring(SpaceshipName)) return false end
	if not Player.SpaceshipName then warn("[PlanetTeleporter]: Did not find SpaceshipName StringValue!") return false end
	
	Player.SpaceshipName.Value = SpaceshipName.Name
	warn("PLANET TP: SPACESHIP ", SpaceshipName.Name)
	
	return true
end

local function RollBackMissionData(Player, Profile)
	-- Sets the active Mission (current ) to false in order to reset
	local Mission = Player.MissionName.Value
	local MissionsFolder = Player:WaitForChild("Missions")
	
	MissionsFolder:FindFirstChild("MissionName").Active.Value = false
	MissionsFolder:FindFirstChild("MissionName").PlayerStatus.Value = ""
	
	warn("[PlanetTeleporter]: Data Rollback was successful for", Player.Name, tostring(Mission))
end

local function UpdateTeleportData(Player, Profile)
	local Data = Profile.Data
	local PlayerTeleportData = Data.PlayerTeleportData
	
	--PlayerTeleportData.Teleport = true
	--PlayerTeleportData.PlanetName = Player.PlanetName.Value
	--PlayerTeleportData.MissionName = Player.MissionName.Value
	--PlayerTeleportData.SpaceshipType = Player.SpaceshipName.Value
	
	TeleportData.Initialize(Player)
	
	print("[PlanetTeleporter]: Updated Profile Data Successfully")
end

local function InitiateTeleport(Player)
	
	while ServerScriptService.Values.ReadyForTP.Value == false do task.wait(0.2) end
	
	print("[PlanetTeleport]: Initiated Teleportation. Reserving Server and teleporting player", Player.Name)
	
	local ReserveServer = TeleportService:ReserveServer(ServerID)

	local TeleportGui = Player.PlayerGui.TeleportUI
	print("PLANETTP: Sending", TeleportGui)
	TeleportService:TeleportToPrivateServer(ServerID, ReserveServer, {Player},"",nil,TeleportGui)
end

ReplicatedStorage:WaitForChild("RemoteEvents").PlanetTeleport.OnServerEvent:Connect(function(Player, Spaceship) --Animators
	
	local Profile = ProfileModule[Player.Name]
	
	if not Player then warn("[PlanetTeleporter]: Player Profile not found", tostring(Profile), Player.Name) return end	
	if Player.PlanetName.Value == "" or Player.PlanetName.Value == nil  then
		warn("[Teleporter]: ABORT: Teleportation aborted due to an invalid PlanetName")	
		RollBackMissionData(Player, Profile)
		return
	end
	if not UpdateSpaceshipData(Player, Spaceship) then 
		warn("[PlanetTeleporter]: Could not update spaceshipdata.") 
		RollBackMissionData(Player, Profile)
		return 
	end
	
	Player.IsTeleporting.Value = true

	UpdateTeleportData(Player, Profile)
	InitiateTeleport(Player)
end)