--[[
    StudioAnimation (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule → Intro
    Parent: Intro
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local Intro = PlayerGui:WaitForChild("Intro")

local Line = Intro.IntroFrame.Line
local Icon = Intro.IntroFrame.LogoIcon
local StudioName = Intro.IntroFrame.StudioName
local HexaByteName = Intro.IntroFrame.HexabyteName


local LOGO_TWEEN_SPEED = 0.3

local StudioAnimation = {}

function StudioAnimation.Animate()
	---------------------------------------------------------------[LINE ANIMATION]-----------------------------------------------

	local function Rotate()
		for i = 0,90,3 do
			Line.Rotation = i
			task.wait(0.0000001)
		end
	end

	local function FadeInLine()
		for i = 1,0,-0.1 do
			Line.ImageTransparency = i
			task.wait(0.001)
		end
	end

	task.wait(0.2)
	FadeInLine()


	Line:TweenSize(
		UDim2.new(0.127,0,0.038,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		0.9,
		true
	)

	task.spawn(Rotate)
	
	-------------------------------------------------------------------[LOGO ANIMATION]---------------------------------------------
	local function FadeInImage()
		for i = 1,0,-0.1 do
			Icon.ImageTransparency = i
			task.wait(0.001)
		end
	end

	local function FadeInText()
		for i = 1,0,-0.1 do
			StudioName.TextTransparency = i
			task.wait(0.001)
		end
	end
	
	local function FadeInParentStudio()
		for i = 1,0,-0.1 do
			HexaByteName.TextTransparency = i
			task.wait(0.001)
		end
	end
	
	game.SoundService.SFX.Intro:Play()
	task.wait(1)

	task.spawn(FadeInImage)
	task.spawn(FadeInText)

	StudioName:TweenPosition(
		UDim2.new(0.664,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Sine,
		LOGO_TWEEN_SPEED,
		true
	)

	Icon:TweenPosition(
		UDim2.new(0.396,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Sine,
		LOGO_TWEEN_SPEED,
		true
	)

	task.wait(0.5)
	task.spawn(FadeInParentStudio)
	
	HexaByteName:TweenPosition(
		UDim2.new(0.795, 0,0.55, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		LOGO_TWEEN_SPEED,
		true
	)
	
	task.wait(0.8)

	----------------------------------------------------[OUT ANIMATION]-------------------------------------------------------------
	Line:TweenSize(
		UDim2.new(1,0,0.038,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quint,
		0.3,
		true
	)
	task.wait(0.4)

	Icon:TweenPosition(
		UDim2.new(-1,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quint,
		0.2,
		true

	)

	StudioName:TweenPosition(
		UDim2.new(1,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quint,
		0.2,
		true

	)
	
	HexaByteName:TweenPosition(
		UDim2.new(1.5, 0,0.55, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		LOGO_TWEEN_SPEED,
		true
	)

	for i = 0,1,0.1 do
		Line.ImageTransparency = i
		task.wait(0.01)
	end
	
	Icon.Visible = false
	StudioName.Visible = false
	Line.Visible = false
	task.wait(0.2)
end

return StudioAnimation