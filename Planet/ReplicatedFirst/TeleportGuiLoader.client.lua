--[[
    TeleportGuiLoader (LocalScript)
    Path: ReplicatedFirst
    Parent: ReplicatedFirst
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LoadingScreen = TeleportService:GetArrivingTeleportGui()

if LoadingScreen then
	game.SoundService:WaitForChild("Ambience").Teleportation:Play()
	print("[TeleportGuiLoader]: Received Teleport UI")
	local PlayerGui = Player:WaitForChild("PlayerGui")
	task.wait(0.2)
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	
	LoadingScreen.Parent = PlayerGui	--Name: PlanetLoadingFrame
	print(LoadingScreen, LoadingScreen.Parent, type(LoadingScreen))
	print("[TeleportGuiLoader]: Moved!")
	LoadingScreen.PlanetLoadingFrame.Visible = true
	
	LoadingScreen.PlanetLoadingFrame.Zindex = 3	
else
	warn("[TeleportGuiLoader]: Did not receive any teleport UI.")	
	
end
