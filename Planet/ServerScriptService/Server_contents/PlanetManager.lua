--[[
    PlanetManager (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

--Child modules: Each planet modules which manage the entity spawning and lighting
-- this module calls the child module depending on the planet and mission the player is playing

-- Loads the planet preset

--[[
	TREE
	-this
	---Planet32B
		- Lighting
		- BasicMissionData
		- AdvanceMissionData
		- EnityManager (changes depending on the level maybe have a number that manages the diff)
		- PlanetDisaster

]]

local ServerScriptService = game:GetService("ServerScriptService")

local PlanetManager = {}
PlanetManager.__index = PlanetManager

function PlanetManager.new()
	local self = setmetatable({}, PlanetManager)
	
	self.Player = nil

	return self
end


function PlanetManager:Init()
	ServerScriptService:WaitForChild("ServerEvents").DataLoaded.Event:Connect(function(Player)
		task.wait(1)
		
		if not Player then warn("[MissionsManager]: Did not recieve player thru the event", Player) return end
		self.Player = Player
		
		
		print("PlanetManager: ",self.Player.MissionName.Value, self.Player.PlanetName.Value, Player.MissionName.Value, Player.PlanetName.Value)
		self:LoadPlanetData()
	end)
end

function PlanetManager:LoadPlanetData()
	
	if self.Player.PlanetName.Value == "" or self.Player.MissionName.Value == "" then 
		warn("[PlanetManager]: PlanetName", self.Player.PlanetName.Value, " MissionName:", self.Player.MissionName.Value) 
		return
	end
	
	local import = require(script:FindFirstChild(self.Player.PlanetName.Value))
	import.new(self.Player):Init()
end

return PlanetManager