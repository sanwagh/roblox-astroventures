--[[
    Tutorial (ModuleScript)
    Path: ServerScriptService → TutorialHandler
    Parent: TutorialHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local module = {}
module.__index = module

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local Bindables = ServerScriptService:WaitForChild("Bindables")

function module.new(plr)
	local self = setmetatable({}, module)

	self.Player = plr
	self.MissionsFolder = nil

	self.TutorialRunning = false -- acts as a kill switch


	self.TutorialStagesFolder = script.Parent.TutorialStages
	return self
end

function module:Init()
	self:CheckPlayerProgress()
end

local function IsNewPlayer(Missions)
	for _, mission in pairs(Missions:GetChildren()) do
		if mission:HasTag("Mission") then
			if mission.Completed.Value == true then
				return false -- If any mission has been completed, then the player is not a new player				
			end
		end
	end
	return true
end

function module:CheckPlayerProgress()
	warn(self.Player)
	-- If the player is new, enable this
	--Check data, if the player has completed no missions, enable this
	self.MissionsFolder = self.Player:WaitForChild("Missions")

	if not self.MissionsFolder then 
		print("[Tutorial]: Did not find MissionsFolder!")
		return
	end

	if IsNewPlayer(self.MissionsFolder) then
		print("[Tutorial]: Starting tutorial")
		self:StartTutorial()
	end
end

function module:StartTutorial()
	--Fire a remote event: TutorialEvent
	RemoteEvents.TutorialEvent:FireClient(self.Player, "Start") -- (Player, EventType)
	print("Fired RE")

end

function module:ForceKillTutorialProcess()

end

return module