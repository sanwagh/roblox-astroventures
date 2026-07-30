--[[
    IntroController (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local UIControllerModule = require(script.UIControllerModule)
local TimeCalculator = require(script.Parent.Handlers.TimeCalculator)

TimeCalculator.StartRecord()
print("[UIController]: Starting UIContoller Module...")
UIControllerModule.OnInit()
TimeCalculator.EndRecord()
print("[UIController]: Started UIController in", TimeCalculator.DisplayTimeTaken(), "seconds")
TimeCalculator.ClearFunctions()