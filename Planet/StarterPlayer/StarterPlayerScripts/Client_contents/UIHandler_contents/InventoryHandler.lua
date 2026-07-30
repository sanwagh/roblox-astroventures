--[[
    InventoryHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → UIHandler
    Parent: UIHandler
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

-- Main Script that handles the inventory ops

--Script to scripts comms thru bindable funcs

local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedGui = ReplicatedStorage:WaitForChild("Gui")
local TweenService = game:GetService("TweenService")

local Tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.1)

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.BackpackUI = self.PlayerGui:WaitForChild("BackpackUI")
	
	self.Backpack = self.Player:WaitForChild("Backpack")
	
	--Modules
	self.HotbarUIModule = require(script.HotbarUI).new()
	self.InventoryUIModule = require(script.InventoryUI).new()
	
	self.Values = script.Parent.Parent.Values
	
	return self
end

function module:Init()
	task.spawn(function()
		self:BindDataLoadedEvent() --Priority Function
	end)
	task.spawn(function()
		self.HotbarUIModule:Init()
	end)
	task.spawn(function()
		self.InventoryUIModule:Init()
	end)
	
end


--[[ 
	Handles loading of inventory and hotbar func calls, inventory open event bindings
]]


function module:BindDataLoadedEvent()
	-- EX_IMPORTANT: This makes sure that if the event is fired and not captured by the either scritps, it can also be accessed later
	ReplicatedStorage:WaitForChild("RemoteEvents").DataLoaded.OnClientEvent:Connect(function()
		self.Values.DataLoaded.Value = true
	end)
end


function module:CallLoadInventory()
	
end

function module:CallLoadHotbar()
	
end

function module:DisplayHotbar()
	
end

return module
