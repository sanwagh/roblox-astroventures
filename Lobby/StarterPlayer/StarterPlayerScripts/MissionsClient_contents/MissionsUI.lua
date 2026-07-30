--[[
    MissionsUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → MissionsClient
    Parent: MissionsClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

--Managed loading and selection of missions and displaying of all data

local Player:Player = game.Players.LocalPlayer

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

local PlayerGui = Player:WaitForChild("PlayerGui")
local MissionsUI = PlayerGui:WaitForChild("MissionsUI")

local MissionFrameLabels = ReplicatedStorage:WaitForChild("Gui").MissionsFrameLabels

local Values = require(script.Parent.Parent:WaitForChild("Values"))

local MissionsUIManager = {}

--TODO TEST

local function ClearOldMissionInstances()
	for i,v in pairs(MissionsUI.MissionsListFrame.MissionsFrame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

local function MissionCompleted(MissionName)
	local Mission = Player.Missions:FindFirstChild(MissionName)
	
	if not Mission then print("[MissionUI]: Did not find Mission in folder", tostring(MissionName)) return end
	
	if Mission.Completed.Value == true then return true end
	return false
end

local function IsActive(MissionName)
	for i,v in pairs(Player.Missions:GetChildren()) do
		if v.Active.Value == true then
			return true
		end
	end
	return false
end

function MissionsUIManager.LoadMissions()
	ClearOldMissionInstances()
	
	local MissionsFolder = Player:FindFirstChild("Missions")
	if not MissionsFolder then warn("[MissionUI]: Missions Folder is missing!") return end
	
	for i,v in pairs(MissionsFolder:GetChildren()) do
		if CollectionService:HasTag(v, "Mission") then
			if MissionCompleted(v.Name) or IsActive(v.Name) then continue end -- Skip the code below this
			
			local MissionFrame = ReplicatedStorage.Gui.MissionFrame:Clone()
			MissionFrame.Parent = MissionsUI.MissionsListFrame.MissionsFrame
			MissionFrame.Name = v.Name
			MissionFrame.CashLabel.Text = "$"..v.Rewards.Cash.Value
			MissionFrame.ExpLabel.Text = v.Rewards.Exp.Value.." XP"
			MissionFrame.MissionName.Text = v.Name
		end
	end
	Values.MissionsLoaded = true
end

local function ClearOldDescInstances()
	for i,v in pairs(MissionsUI.MissionDescriptionFrame.DescriptionFrame:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
end

local function HasActiveMission()
	for i,v in pairs(Player.Missions:GetChildren()) do
		if CollectionService:HasTag(v, "Mission") then
			if v.Active.Value == true then
				return true
			end
		end
	end
	return false
end

function MissionsUIManager.LoadMissionDescOnClick(MissionName)
	-- In the missinos folder (serStorage) each mission can have a module with the desc and req. As the module is in the 
	--player instance, it can be accessed by the client
	ClearOldDescInstances()
	
	MissionsUI.MissionDescriptionFrame.Visible = true
	
	local MissionFolder = Player.Missions:FindFirstChild(MissionName)
	
	if not MissionFolder then warn("[MissionUI]: Mission folder was not found while loading desc", tostring(MissionName)) return end
	
	local MissionDataModule = require(MissionFolder.ClientData)
	
	local DescriptionTable = MissionDataModule.Description
	local RequirementsTable = MissionDataModule.Requirements
	
	local DescTitleClone = MissionFrameLabels.DescriptionTitle:Clone()
	DescTitleClone.Parent = MissionsUI.MissionDescriptionFrame.DescriptionFrame
	
	for i,v in pairs(DescriptionTable) do
		local DescClone = MissionFrameLabels.DescriptionLabel:Clone()
		DescClone.Parent = MissionsUI.MissionDescriptionFrame.DescriptionFrame
		DescClone.Text = v
	end
	
	local ReqTitleClone = MissionFrameLabels.RequirementTitle:Clone()
	ReqTitleClone.Parent = MissionsUI.MissionDescriptionFrame.DescriptionFrame
	
	for i,v in pairs(RequirementsTable) do
		local ReqClone = MissionFrameLabels.RequirementLabel:Clone()
		ReqClone.Parent = MissionsUI.MissionDescriptionFrame.DescriptionFrame
		ReqClone.Text = v
	end
	
	--Check if a mission is already active before and change the btn text for AcceptBtn
	if HasActiveMission() then
		MissionsUI.MissionDescriptionFrame.AcceptBtn.Text = "A mission is active!"
	else
		MissionsUI.MissionDescriptionFrame.AcceptBtn.Text = "Accept"
	end
	
	MissionsUI.MissionDescriptionFrame.AcceptBtn.MouseButton1Down:Connect(function()
		game.SoundService.SFX.SecondaryClick:Play()
		--Check for active missions again, then tween out the ui and set blur to 0
		if HasActiveMission() then print("[MissionUI]: Player already has a mission active!") return end
		
		local Tween = TweenService:Create(MissionsUI.MissionsListFrame, Tweeninfo, {Position = UDim2.new(-0.5,0,0.5,0)})
		
		Tween:Play()
		
		task.spawn(function()
			for i = 12,0,-0.2 do
				game.Lighting.Blur.Size = i
				task.wait(0.001)
			end
		end)
		
		
		MissionsUI.MissionDescriptionFrame.Visible = false
		
		local PlanetName = Player.Missions:FindFirstChild(MissionName).PlanetName.Value
		
		ReplicatedStorage.RemoteEvents.MissionEvent:FireServer("StartMission", {MissionName, PlanetName})
	end)
end


return MissionsUIManager

