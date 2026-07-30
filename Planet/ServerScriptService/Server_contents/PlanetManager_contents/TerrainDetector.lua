--[[
    TerrainDetector (ModuleScript)
    Path: ServerScriptService → Server → PlanetManager
    Parent: PlanetManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local TerrainDetector = {}
TerrainDetector.__index = TerrainDetector

function TerrainDetector.new()
	local self = setmetatable({}, TerrainDetector)
	
	self.Terrain = game.Workspace:WaitForChild("Terrain")
	self.DetectorPartsFolder = nil
	self.Detections = {}
	
	return self
end

local function GetDetectorParts()
	return game.Workspace:WaitForChild("DetectorParts")
end

local function GetDetectionPoints(DetectorPartsFolder)
	local DetectionPoints = {}
	for i,parts in pairs(DetectorPartsFolder:GetChildren()) do
		if parts:IsA("Parts") then
			DetectionPoints[parts.Name] = false
		end
	end
	
	return DetectionPoints
end

function TerrainDetector:WaitForCollisions(Part:Part)
	warn("[TerrainDetector]: Checking collisions with ray from", Part)
	
	while true do
		task.wait(0.1)
		local Direction = Part.CFrame.LookVector
		local ray = game.Workspace:Raycast(Part.Position, Direction)
		
		if not ray then continue end
		warn(ray, ray.Distance)
		if ray.Distance <= 1.5 then break end
		task.wait(0.9)
	end
	print("[TerrainDetector]:", Part.Name, " Detected a collision")
	return true
end

function TerrainDetector:WaitForLoad()
	self.DetectorPartsFolder = GetDetectorParts()
	self.Detections = GetDetectionPoints(self.DetectorPartsFolder)
	
	for i,part in pairs(self.DetectorPartsFolder:GetChildren()) do
		if not part:IsA("Part") then continue end
		
		local CollisionDetected = self:WaitForCollisions(part)
		print(CollisionDetected)
		
		self.Detections[part.Name] = CollisionDetected
	end

	local Flags = 0
	
	for i,v in pairs(self.Detections) do
		if v == true then
			Flags += 1
		end
	end
	
	if Flags >= #self.Detections then
		return true
	end
end

return TerrainDetector