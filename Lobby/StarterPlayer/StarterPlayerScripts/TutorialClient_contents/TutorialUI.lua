--[[
    TutorialUI (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TutorialClient
    Parent: TutorialClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local TweenService = game:GetService("TweenService")
local Tweeninfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false, 0)

--TODO TEST!!!

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	
	self.TutorialUI = self.PlayerGui:WaitForChild("TutorialUI")
	self.TutorialFrame = self.TutorialUI.TutorialFrame
	self.ButtonFrame = self.TutorialFrame.ButtonFrame
	
	self.TutorialText = self.TutorialFrame.TutorialText
	
	self.TutorialEnabled = false
	self.Text = ""
	
	self.TutorialFramePosition = UDim2.new({0.596, 0},{0.911, 0})
	
	--Buttons
	self.VisibilityChangeBtn = self.TutorialFrame.VisibilityChangeBtn
	self.NextBtn = self.ButtonFrame.NextBtn

	--Connections
	self.VISIBILITY_BTN_CONNECTION = nil
	
	return self
end

function module:Init()
	self:ShowUI()
end

function module:ShowUI()
	self.TutorialFrame.Visible = true
	self.ButtonFrame.Visible = true
end


function module:MoveUIOffScreen()
	--if not self.TutorialFramePosition then self.TutorialFramePosition = self.TutorialFrame.Position end
	warn(self.TutorialFramePosition, self.TutorialFramePosition.X)
	local Tween = TweenService:Create(self.TutorialFrame,
		Tweeninfo,
		{Position = UDim2.new(0.594, 0, 1.066,0)}
	)
	
	game.SoundService.SFX.SecondaryClick:Play()
	Tween:Play()
	
	self.VisibilityChangeBtn.Display.Rotation = 180
end

function module:MoveUIOnScreen()
	local Tween = TweenService:Create(self.TutorialFrame,
		Tweeninfo,
		{Position = UDim2.new(0.594, 0, 0.911,0)}
	)

	game.SoundService.SFX.SecondaryClick:Play()
	Tween:Play()
	self.VisibilityChangeBtn.Display.Rotation = 0
end

function module:TextAnimation(Text)
	for i = 1, #Text do
		self.TutorialText.Text = string.sub(Text, 1, i)
		task.wait(0.005)
	end	
end

--Button Click Detectors [STANDALONE FUNCTION]
function module:ButtonDetector()
	-- Visibility Change Button-------------------------------------------------------------------------------------
	if self.VISIBILITY_BTN_CONNECTION then self.VISIBILITY_BTN_CONNECTION:Disconnect() end
	
	self.VISIBILITY_BTN_CONNECTION = self.VisibilityChangeBtn.MouseButton1Down:Connect(function()
		if self.VisibilityChangeBtn.Open.Value == true then
			-- The UI is visible and on top
			self:MoveUIOffScreen()
			self.VisibilityChangeBtn.Open.Value = false
			self.VisibilityChangeBtn.Transparency = 0.5
		else
			self:MoveUIOnScreen()
			self.VisibilityChangeBtn.Open.Value = true
			self.VisibilityChangeBtn.Transparency = 0
		end
	end)
end

return module
