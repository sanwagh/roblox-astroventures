--[[
    ServerLoading (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local Values = script.Parent.Values

local ServerLoading = {}
ServerLoading.__index = ServerLoading


--Checks if the server has been loaded or not (Terrain and player data then fires a remote event)

function ServerLoading.new()
	local self = setmetatable({}, ServerLoading)
	
	self.ReplicatedStorage = game:GetService("ReplicatedStorage")
	self.RemoteFunctions = self.ReplicatedStorage:WaitForChild("RemoteFunctions")
	
	self.Terrain = game.Workspace:WaitForChild("Terrain")
	
	return self
end

function ServerLoading:Init()
	self:WaitForBasicLoad()
	task.spawn(function()
		self:CountTerrainCells()
	end)
end



function ServerLoading:WaitForBasicLoad()
	--waits for the terrain and data
	while Values.DataLoaded.Value == false or Values.TerrainLoaded.Value == false do
		task.wait(0.2)
	end
	
	print("[ServerLoading]: Data and the map have loaded. Firing all clients")
	
	game.ReplicatedStorage.RemoteEvents.GameLoaded:FireAllClients()
end

function ServerLoading:CountTerrainCells()
	print("[ServerLoading]: Terrain Cell count:", self.Terrain:CountCells())
	game.ReplicatedStorage.RemoteFunctions.CountCells.OnServerInvoke = function()
		return self.Terrain:CountCells()
	end
end

return ServerLoading