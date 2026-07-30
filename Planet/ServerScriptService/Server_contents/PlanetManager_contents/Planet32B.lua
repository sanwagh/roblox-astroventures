--[[
    Planet32B (ModuleScript)
    Path: ServerScriptService → Server → PlanetManager
    Parent: PlanetManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TerrainLoadingEngine = require(script.Parent.TerrainSaveLoad)
local TerrainLoadDetection = require(script.Parent.TerrainDetector)
local Values = ServerScriptService.Server.Values

local Planet = {}
Planet.__index = Planet

function Planet.new(player)
	local self = setmetatable({}, Planet)
	
	self.Player = player
	
	self.LoadedTerrain = false
	self.LoadedLighting = false
	
	self.PLANET_NAME = "Planet32B"
	print(player, player:WaitForChild("SpaceshipName"))
	self.SpaceshipName = nil
	
	return self
end

function Planet:Init()
	-- Loads the terrain, Lighting(skybox as well), Calls Entity Manager (spawns mobs and other npcs or items), Calls
	--the module for decoration (trees, rocks etc)
	self:LoadTerrainData()
	self:LoadLighting()
	self:LoadDecoration()
	task.wait(0.2) -- fallback incase there is some server latency while loading
	self:PostLoading()
end

local function GetTerrainDataKey(PlanetName) :Instance
	return ServerStorage.PlanetData[PlanetName].TerrainData
end

local function LoadDetectorParts(PlanetName)
	local DetectorParts = ServerStorage.PlanetData[PlanetName]:FindFirstChild("DetectorParts")
	local FolderClone = DetectorParts:Clone()
	FolderClone.Parent = workspace
end

function Planet:LoadTerrainData()
	local TerrainKey = GetTerrainDataKey(self.PLANET_NAME)
	if not TerrainKey then warn("[PlanetLoader]: Did not find key for ", self.PLANET_NAME,". Aborting Loading. Teleporting to Lobby") return end
	
	print("[PlanetLoader]: Loading Terrain|", self.PLANET_NAME)
	TerrainLoadingEngine.Load(TerrainKey)
	--add a wait for load. Add detector parts
	
	LoadDetectorParts(self.PLANET_NAME)
	TerrainLoadDetection.new():WaitForLoad()	
	print("[PlanetLoader]: Loaded Terrain succesfully! |", self.PLANET_NAME)
	
	Values.TerrainLoaded.Value = true
end

function Planet:LoadLighting()
	local LightingModule = require(script.LightingData)
	
	for i,data in pairs(LightingModule.Lighting) do
		game.Lighting[i] = data
	end
	
	game.Lighting:ClearAllChildren()
	
	for i, data in pairs(script.LightingData.Lighting:GetChildren()) do
		data:Clone().Parent = game.Lighting
	end
	print("[PlanetLoader]: Loaded Lighting and env effects succesfully! |", self.PLANET_NAME)
end

function Planet:LoadDecoration()
	local DecorationFolder = ServerStorage.PlanetData:FindFirstChild(self.PLANET_NAME).Models
	if not DecorationFolder then warn("[PlanetLoader]: Could not find decoration for the planet. Continuing..|", self.PLANET_NAME) return end
	
	DecorationFolder:Clone().Parent = game.Workspace
end

local function GetSpawnPosition(): CFrame
	local ModelsFolder = game.Workspace:FindFirstChild("Models")
	
	if not ModelsFolder then 
		warn("[PlanetLoader]: Could not locate the planet models folder in the workspace. It may not be loaded...")
		return nil
	end
	
	local LandingPos = ModelsFolder:FindFirstChild("SpaceshipSpawn")
	
	if not ModelsFolder then 
		warn("[PlanetLoader]: Could not locate the planet models folder in the workspace. It may not be loaded...")
		return nil
	end
	return LandingPos.CFrame
end

function Planet:SpawnSpaceship()
	warn("PLANET32B: ", self.SpaceshipName)
	local Ship = ServerStorage.Spaceships:FindFirstChild(tostring(self.SpaceshipName)):Clone()
	Ship.Parent = workspace
	
	local Pos = GetSpawnPosition()
	
	if not Pos then return end
	
	Ship.PrimaryPart.CFrame = Pos
	print("[PlanetLoader]: Loaded Spaceship into the world")
	
	Ship = nil
	Pos = nil
end

local function InformClient(Player)
	game.ReplicatedStorage.RemoteEvents.PlanetDataLoaded:FireClient(Player)
end

local function InformServer(Player)
	game.ServerScriptService.ServerEvents.PlanetDataLoaded:Fire()
end

function Planet:PostLoading()
	self.SpaceshipName = self.Player.SpaceshipName.Value
	warn("PLANET32: post loaded set spaceship name", self.SpaceshipName, self.Player.SpaceshipName.Value)
	
	if not self.SpaceshipName or self.SpaceshipName.Value == "" then warn("[PlanetLoader]: nil Spaceship.", self.SpaceshipName) return end
	
	self:SpawnSpaceship()
	
	print("[PlanetLoading]: Informing Server and client")
	InformClient(self.Player)
	InformServer()
	
	
	print("[PlanetLoading]: Completed loading proceedure with no errors for ", self.PLANET_NAME)
end

function Planet:WaitForAnimationFinish()
	game.ReplicatedStorage.RemoteEvents.Animation.OnServerEvent:Connect(function(EventType)
		if EventType == "LandingCompletion" then
			self.SpaceshipName.PrimaryPart.Position = game.Workspace.Models.LandingPos.Position
		end
	end)
end

return Planet