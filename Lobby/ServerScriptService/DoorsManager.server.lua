--[[
    DoorsManager (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--Use a module for the doors operation.
-- Store all the doors in a folder and use individual scripts for each door type
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomDoorsModule = require(script.RoomDoors)
local BayDoorsModule = require(script.BayDoors)

local RoomDoorFolder = game.Workspace:WaitForChild("Doors").RoomDoors



local function GetDoorData(DoorName, RetType)
	for i,folder in pairs(game.Workspace.Doors:GetChildren()) do
		for i,door in pairs(folder:GetChildren()) do
			if door.Name == DoorName then
				if RetType == "Door" then return door end
				if RetType == "DoorFolder" then return folder end
			end
		end
	end
end
--Room Doors function

task.spawn(function()
	for i,v in pairs(game.Workspace:WaitForChild("Doors"):GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.Triggered:Connect(function(Player)
				local DoorName = v.Parent.DoorName.Value

				local Door = GetDoorData(DoorName, "Door")
				local DoorFolder = GetDoorData(DoorName, "DoorFolder")
			
				local Module = require(script:FindFirstChild(DoorFolder.Name))
				print(DoorName, DoorFolder, Module)
				
				if v.Name == "OpenPrompt" then
					print("Open!")
					Module.OpenDoor(Player,Door)
				elseif v.Name == "ClosePrompt" then
					Module.CloseDoor(Player, Door)
				end
			end)
		end
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function()
		BayDoorsModule.Init(Player)
	end)
end)


--Event for closing doors when takeoff.
ReplicatedStorage.RemoteEvents.DoorEvent.OnServerEvent:Connect(function(Player, Status, DoorName)
	print(DoorName)
	local DoorFolder = GetDoorData(DoorName, "DoorFolder")
	print(DoorFolder)
	local Door = DoorFolder:FindFirstChild(DoorName)
	local Module = require(script:FindFirstChild(DoorFolder.Name))
	
	print(Door)
	
	for i,v in pairs(Door:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.Name == "ClosePrompt" then
			Module.CloseDoor(Player, Door)
		end
	end
end)