--[[
    BugReporter (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local BugRepMod = require(script:WaitForChild("BugReportServer"))

BugRepMod.new():Init()