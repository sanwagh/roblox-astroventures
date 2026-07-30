--[[
    PlayerData (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local DataService = require(script.DataService)
local TimeCalculator = require(script.Parent.Handlers.TimeCalculator)

TimeCalculator.StartRecord()

print("[DataService]: Starting the DataService...")
DataService.OnInit()

TimeCalculator.EndRecord()
print("[DataService]: Started DataService in",(TimeCalculator.DisplayTimeTaken()), " Seconds")
TimeCalculator.ClearFunctions()