--[[
    TutorialManager (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

-- Works side by side with the mission.

-- UI is also managed by the server!
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = ""
	self.PlanetName = ""
	self.MissionName = ""
	
	self.PlayerGui = ""
	self.TutorialGui = ""
	
	return self
end


function module:Init()
	RemoteEvents.TriggerTutorial.OnServerEvent:Connect(function(player:Player)
		print("[Tutorial]: Initializing tutorial...")
		if not player then warn("[TutorialManager]: Player not found. Exiting") return end
		
		self.Player = player
		
		if not self.Player.MissionName.Value then warn("[TutorialManager]: Mission Not found", self.Player.MissionName.Value) return end
		if not self.Player.PlanetName.Value then warn("[TutorialManager]: Planet name not found", self.Player.PlanetName.Value) return end
		
		self.PlanetName = self.Player.PlanetName.Value
		self.MissionName = self.Player.MissionName.Value
		
		-- Strong sanity check to make sure PlayerGui is loaded in.
		-- This is done to make sure that any other server processes dont halt due to an error here.
		if not self.Player:FindFirstChild("PlayerGui") then 
			warn("[TutorialManager]: PlayerGui might not have loaded in. Pausing further execution")
			self.Player:WaitForChild("PlayerGui")
			warn("[TutorialManager]: PlayerGui located. Resuming execution")
		end
		
		self.Player.PlayerGui = self.Player.PlayerGui
	end)	
end

function module:StartTutorial()
	-- Displaying the dialogs should be preceeded with the name of the speaker
end

return module