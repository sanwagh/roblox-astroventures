--[[
    BugReporterClient (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local BugRepMod = require(script:WaitForChild("BugReportClient"))

BugRepMod.new():Init()