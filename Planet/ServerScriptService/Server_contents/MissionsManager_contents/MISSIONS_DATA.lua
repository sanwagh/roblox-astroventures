--[[
    MISSIONS_DATA (ModuleScript)
    Path: ServerScriptService → Server → MissionsManager
    Parent: MissionsManager
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

-- Complies all the data in here based on the mission name
--[[
	- All the data in the modules will be manipulated at all times. 
	- Call this module only when the client needs the data
	- When neeed the server Flushes the data to the client
]]

local MissionData = {}

local DataTable = {}
local ModuleTable = {}


function MissionData.FetchData(Player) -- returns table
	-- use remote func calls
	local MissionName = Player:WaitForChild("MissionName").Value
	
	if not MissionName or MissionName == "" then warn("[MISSION_DATA]: Mission not found!", MissionName) return end
	if not script:FindFirstChild(MissionName.."Data") then warn("[MISSION_DATA]: Could not find data for mission", MissionName) return end
	
	local DataModule = script:FindFirstChild(MissionName.."Data")
	return MissionData.CompileData(MissionName, DataModule)
end

-- Compiles all the Data modules into a single table everytime this module is called
function MissionData.CompileData(MissionName, DataModule) -- returns Table
	print("[MISSION_DATA]: Compiling Data for", MissionName, "from", tostring(DataModule.Name))
	
	local Import = require(DataModule)
	
	DataTable = Import
	DataTable[MissionName.."Data"].Tasks = {}
	
	for i, module:ModuleScript in ipairs(DataModule:GetChildren()) do
		if not module:IsA("ModuleScript") then continue end
		
		local TaskTable = require(module)
		
		
		DataTable[MissionName.."Data"].Tasks[module.Name] = TaskTable
	end
	print("[MISSION_DATA]: Compiliation of Data successful for", MissionName, "from", tostring(DataModule.Name))
	print(DataTable)
	
	return DataTable
end


return MissionData