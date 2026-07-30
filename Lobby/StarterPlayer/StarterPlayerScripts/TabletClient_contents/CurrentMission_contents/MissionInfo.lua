--[[
    MissionInfo (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient → CurrentMission
    Parent: CurrentMission
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MissionInfoFrame = PlayerGui:WaitForChild("TabletUI").TabletFrame.ScreenFrame.MissionFrame.MissionInfoFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceId = game.PlaceId --If it is the planet sub place, show sm stuff

local MissionInfo = {}

function MissionInfo.Init()
	--Tells the player what the planet has, what to be aware of
	MissionInfo.Display()
end

function MissionInfo.Display()
	local MissionName = Player.MissionName.Value
	local MissionsFolder = Player.Missions:FindFirstChild("MissionName")
	
	if not MissionsFolder then warn("[MissionInfo]: Could not find Mission info") return end
	
	MissionInfoFrame.Info.Text = MissionsFolder.MissionInfo.Value
end

return MissionInfo