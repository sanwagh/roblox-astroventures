--[[
    OnInvokeTest (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Client → Events → ToInventory
    Parent: ToInventory
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]


script.Parent.OnInvoke = function(Player, EE, ER)
	print("TEST", Player, EE, ER)
end