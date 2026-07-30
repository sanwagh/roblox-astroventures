--[[
    ClientTerrainCheck (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client
    Parent: Client
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local TerrainCheck = {}
TerrainCheck.__index = TerrainCheck

function TerrainCheck.new()
	local self = setmetatable({}, TerrainCheck)
	
	self.Values = script.Parent.Values
	
	self.ReplicatedStorage = game:GetService("ReplicatedStorage")
	self.RemoteEvents = self.ReplicatedStorage:WaitForChild("RemoteEvents") 
	
	self.RemoteFunctions = self.ReplicatedStorage:WaitForChild("RemoteFunctions")
	self.Terrain = game.Workspace:WaitForChild("Terrain")
	
	return self
end

--Checks if the terrain has been loaded on the Client or not after the gameloaded event
function TerrainCheck:Init()
	task.spawn(function()
		print("WAITING FOR VAL")
		while self.Values.GameLoadedEventFired.Value == false do task.wait(0.1) end

			print("CHECKING TERRAIN")
			self:CheckForLoad()
	end)
	return
end

function TerrainCheck:CheckForLoad()
	local ServerCells, ClientCells
	print("[ClientTerrainCheck]: Loading terrain on client...")
	local Tick = tick()
	
	repeat
		ServerCells = self.RemoteFunctions.CountCells:InvokeServer()
		ClientCells = self.Terrain:CountCells()
		print(ClientCells,"/",ServerCells, " loaded")
	until ClientCells >= ServerCells
	
	
	print("[ClientTerrainCheck]: Replicated Terrain to the Client in ", tick() - Tick, " seconds")

	self.Values.TerrainLoaded.Value = true
end

return TerrainCheck