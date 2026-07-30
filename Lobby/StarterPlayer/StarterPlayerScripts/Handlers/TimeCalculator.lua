--[[
    TimeCalculator (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Handlers
    Parent: Handlers
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TimeCalculator = {}

local StartTime
local EndTime
local TotalTime

function TimeCalculator.StartRecord()
	StartTime = os.time()
end

function TimeCalculator.EndRecord()
	EndTime = os.time()
end

function TimeCalculator.DisplayTimeTaken()
	return EndTime - StartTime
end

function TimeCalculator.ClearFunctions()
	StartTime = nil
	EndTime = nil
	TotalTime = nil
	
	TimeCalculator = {}
	return
end

return TimeCalculator