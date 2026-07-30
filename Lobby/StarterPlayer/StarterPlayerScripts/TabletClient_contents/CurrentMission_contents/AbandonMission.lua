--[[
    AbandonMission (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient → CurrentMission
    Parent: CurrentMission
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local AbandonFrame = PlayerGui:WaitForChild("TabletUI").TabletFrame.ScreenFrame.MissionFrame.AbandonTaskFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfirmBtnConnection = nil
local CancelBtnConnection = nil

local PlaceID = 140214143174948

local AbandonMission = {}

function AbandonMission.Init()
	--Show a ui asking if the player wants to abandon
	AbandonFrame.Visible = true

end



local function HasPenalty()
	if game.PlaceId == PlaceID then
		warn("[Abandon Mission]: Penalizing Player for abandoning the mission while is was running!", 
			Player.Name, 
			tostring(Player.MissionName.Value))
		return true	
	else
		return false
	end
end


function AbandonMission.OnConfirm()
	game.SoundService.SFX.Click:Play()
	local Penality = false
	
	if HasPenalty() then
		Penality = true
	else
		Penality = false
	end
	ReplicatedStorage.RemoteEvents.MissionEvent:FireServer("AbortMission",{Penality}) --[PlayerName, EventType, Data]
	print("[AbandonMission]: Requesting server to abandon current mission...")
end

function AbandonMission.OnCancel()
	game.SoundService.SFX.SecondaryClick:Play()
	AbandonFrame.Visible = false
end

AbandonFrame.ConfirmBtn.MouseButton1Down:Connect(function()
	AbandonMission.OnConfirm()
end)

AbandonFrame.CancelBtn.MouseButton1Down:Connect(function()
	AbandonMission.OnCancel()
end)

return AbandonMission