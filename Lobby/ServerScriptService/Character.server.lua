--[[
    Character (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local SCALE = 1.2

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Char)
		local Humanoid = Char:WaitForChild("Humanoid")
		Humanoid.HeadScale.Value *= SCALE
		Humanoid.BodyDepthScale.Value *= SCALE
		Humanoid.BodyWidthScale.Value *= SCALE
		Humanoid.BodyHeightScale.Value *= SCALE
	end)
end)