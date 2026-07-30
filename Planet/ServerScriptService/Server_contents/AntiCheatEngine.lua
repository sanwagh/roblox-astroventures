--[[
    AntiCheatEngine (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	return self
end

function module:Init()
	self:BindEvents()
end

function module:BindEvents()
	RemoteEvents.AntiCheatEvents.OnServerEvent:Connect(function(Player, Action, Message)
		if Action == "KickPlayer" then
			self:KickPlayer(Player, Message)
		end
	end)
end

function module:KickPlayer(Player:Player, Message)
	Player:Kick(Message)
end

return module
