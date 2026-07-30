--[[
    BackpackHandler (ModuleScript)
    Path: ServerScriptService → Server
    Parent: Server
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

--Handles equip and unequip funcs
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ErrorCodes = require(script.Parent.ServerErrorCodes)

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	return self
end

function module:Init()
	self:BindEvent()
end

local function PassedChecks(player, Item)
	--Cross verify with the server stored tools
	if not ServerStorage.Items.Tools:FindFirstChild(Item.Name) then
		warn("[ERROR][BackpackHandler]:", ErrorCodes.CompileErrorMsg("GP3001"))
		return false
	end 

	-- Check if the backpack has the tool
	if not player.Backpack:FindFirstChild(Item.Name) and not player.Character:FindFirstChild(Item.Name) then
		warn("[ERROR][BackpackHandler]:", ErrorCodes.CompileErrorMsg("GP3002"))
		return false
	end
	return true
end

function module:BindEvent()
	RemoteEvents.InventoryEvent.OnServerEvent:Connect(function(player, Type, Item)
		if Type == "Equip" then
			if not PassedChecks(player, Item) then return end
			
			local Item = ServerStorage.Items.Tools:FindFirstChild(Item.Name)
			self:EquipItem(player, Item)
			
		elseif Type == "Unequip" then
			if not PassedChecks(player, Item) then return end
			
			local Item = ServerStorage.Items.Tools:FindFirstChild(Item.Name)
			
			
			self:UnequipItem(player, Item)
		end		
	end)
end

function module:EquipItem(player:Player, item)
	local Item = player.Backpack:FindFirstChild(item.Name)
	local Char = player.Character or player.CharacterAdded:Wait()
	
	if not Item then
		print("[ERROR]", ErrorCodes.CompileErrorMsg("GP3002"), player.Name)
		return
	end
	
	Char.Humanoid:EquipTool(Item)
	Item:SetAttribute("Equipped", true)
end

function module:UnequipItem(player, Item)
	
	if not Item then
		return
	end

	local Char = player.Character or player.CharacterAdded:Wait()

	Char.Humanoid:UnequipTools()
	Item:SetAttribute("Equipped", false)
end

function module:DropItem(player, item)
	local Char = player.Character or player.CharacterAdded:Wait()
	
	local Item = player.Backpack:FindFirstChild(item.Name)
	Item.Parent = workspace
	Item.Position = Char.HumanoidRootPart.Position + Vector3.new(2,0,2)
end

return module
