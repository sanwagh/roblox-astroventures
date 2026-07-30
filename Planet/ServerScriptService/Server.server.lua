--[[
    Server (Script)
    Path: ServerScriptService
    Parent: ServerScriptService
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

for i,modules in ipairs(script:GetChildren()) do
	if modules:IsA("ModuleScript") and modules:GetAttribute("Priority") and not modules:GetAttribute("Exempt") then
		local import = require(modules)
		print("[SERVER}: Loading PRIORITY module:", tostring(modules.Name))
		local Call = import.new()

		Call:Init()
	end
end

print("[SERVER]: Loaded Priority Modules!")

for i,modules in ipairs(script:GetChildren()) do
	if modules:IsA("ModuleScript") and not modules:GetAttribute("Priority") and not modules:GetAttribute("Exempt")  then
		local import = require(modules)
		print("[SERVER}: Loading  module:", tostring(modules.Name))
		local Call = import.new()

		Call:Init()
	end
end