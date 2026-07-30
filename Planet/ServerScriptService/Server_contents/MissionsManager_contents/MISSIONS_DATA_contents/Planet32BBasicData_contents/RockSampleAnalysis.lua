--[[
    RockSampleAnalysis (ModuleScript)
    Path: ServerScriptService → Server → MissionsManager → MISSIONS_DATA → Planet32BBasicData
    Parent: Planet32BBasicData
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module = {}

module.Completed = false

module.Data = {
	--Names of rocks collected will be present with their rarity
}

module.Desc = [[Collect rocks found nearby and take them to the research shelter to investigate them. You can either
scan them to get data about them, use them for tools or other buildings or take them back to the space station. Also 
make sure to log your observations in the log book on this tab.]]

return module
