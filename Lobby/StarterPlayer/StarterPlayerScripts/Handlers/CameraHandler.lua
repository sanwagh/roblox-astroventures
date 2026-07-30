--[[
    CameraHandler (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Handlers
    Parent: Handlers
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer

local Camera = game.Workspace.CurrentCamera

local CameraController = {}

function CameraController.SetCameraType(CamType)
	if Enum.CameraType[CamType] then
		Camera.CameraType = Enum.CameraType[CamType]
	else
		warn("[CameraController]:Camera type " .. CamType .. " does not exist")
	end
end

function CameraController.SetCameraPos(CameraPos)
	if typeof(CameraPos) ~= "CFrame" then
		warn("[CameraController]: CameraPos is not a CFrame ", typeof(CameraPos))
		return
	end 
	Camera.CFrame = CameraPos
end

function CameraController.SetCameraSubject(Subject)
	if not Subject then warn("[CameraController]: Subect is not valid. Preferably use a humanoid.") return end
	
	Camera.CameraSubject = Subject
end

return CameraController