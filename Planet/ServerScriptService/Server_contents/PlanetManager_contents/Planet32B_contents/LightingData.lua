--[[
    LightingData (ModuleScript)
    Path: ServerScriptService → Server → PlanetManager → Planet32B
    Parent: Planet32B
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local module = {}

module.Lighting = {
	["Ambient"] = Color3.fromRGB(58,58,58),
	["Brightness"] = 2,
	["ColorShift_Bottom"] = Color3.fromRGB(255, 255, 255),
	["ColorShift_Top"] = Color3.fromRGB(253, 253, 253),
	["EnvironmentDiffuseScale"] = 1,
	["EnvironmentSpecularScale"] = 1,
	["GlobalShadows"] = true,
	["OutdoorAmbient"] = Color3.fromRGB(93,93,93),
	["ShadowSoftness"] = 0.52,
	["ClockTime"] = 12,
	["GeographicLatitude"] = 0,
	["ExposureCompensation"] = 0.0,

}



return module
