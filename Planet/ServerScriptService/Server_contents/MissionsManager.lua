--[[
    MissionsManager (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionsManager = {}
MissionsManager.__index = MissionsManager

--TODO LOAD THE PLAYER MISSION DATA INTO THE MODULE

function MissionsManager.new()
	local self = setmetatable({}, MissionsManager)

	self.Player = ""
	self.MissionName = ""
	self.PlanetName = ""
	self.Missions = nil

	return self
end


function MissionsManager:Init()
	ServerScriptService:WaitForChild("ServerEvents").DataLoaded.Event:Connect(function(Player)
		if not Player then warn("[MissionsManager]: Did not recieve player thru the event") return end
		
		self.Player = Player.Name
		self.MissionName = Player.MissionName.Value
		self.PlanetName = Player.PlanetName.Value
		

		--local MissionsFolder = ServerStorage:WaitForChild("Missions"):Clone()
		--MissionsFolder.Parent = Player

		--self.Missions = MissionsFolder
		--print("[MissionsManager]: Cloned Missions Folder!")
		
		print("starting mission")
		self:StartPlanetMission()
	end)
end

function MissionsManager:StartPlanetMission()
	local Mission = script:FindFirstChild(self.MissionName)
	
	if not Mission then warn("[MissionManger]: No such mission found!", self.MissionName) return end
	
	local MissionModule = require(Mission)
	local Call = MissionModule.new()
	
	print("[MissionManager]: Starting Mission", self.MissionName)
	Call:Init(self.Player)
end



-- Sends MissionData to client on request
ReplicatedStorage:WaitForChild("RemoteFunctions").FetchData.OnServerInvoke = function(Player)
	print("Called")
	return require(ServerScriptService.Server.MissionsManager.MISSIONS_DATA).FetchData(Player)
end


return MissionsManager