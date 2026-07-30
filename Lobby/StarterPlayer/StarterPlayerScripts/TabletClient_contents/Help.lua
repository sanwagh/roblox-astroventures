--[[
    Help (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TabletClient
    Parent: TabletClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local HelpFrame = PlayerGui:WaitForChild("TabletUI").TabletFrame.ScreenFrame.HelpFrame

local Counter = 6
local InHelp = true

local Help = {}

local HelpText = {
	"undefined",
	"Just contact the developers..."
}

function Help.Init()
	InHelp = true
	HelpFrame.Visible = true
	HelpFrame.Parent.MenuFrame.Visible = false
end

local function SetDefaultParams(label)
	--sets the TextLabel on instantiating it
end

local function AnimateText(text)
	for i = 1, #text do
		HelpFrame.Desc.Text = string.sub(text, 1, i)
		task.wait(0.05)
	end
end


function Help.DisplayHelp()
	HelpFrame.Desc.Text = "undefined"
	
	while InHelp and Counter > 0 do
		task.wait(1)
		Counter += 1
	end
	AnimateText("Just...Just contact the developers.")
end

HelpFrame.BackBtn.MouseButton1Down:Connect(function()
	InHelp = false
	HelpFrame.Visible = false
	HelpFrame.Parent.MenuFrame.Visible = true
end)

return Help
