--[[
    Intro (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule
    Parent: UIControllerModule
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local IntroUI = PlayerGui:WaitForChild("Intro")

local CameraHandler = require(script.Parent.Parent.Parent.Handlers.CameraHandler)
local MainMenu = require(script.Parent.MainMenu)
local StudioAnimation = require(script.StudioAnimation)

local TweenService = game:GetService("TweenService")
local Tweeninfo  = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In,0,false, 0)

local CoreGui = game:GetService("StarterGui")


local WaitTime = 0.5

local Intro = {}

function Intro.OnInit()
	task.spawn(Intro.StartIntro)
	CameraHandler.SetCameraType("Scriptable")
	CameraHandler.SetCameraPos(game.Workspace:WaitForChild("Decoration").Cameras:WaitForChild("IntroCameraPart").CFrame)
end

local function FetchVersionName()
	return game.ReplicatedStorage:WaitForChild("Values").GAME_VERSION_NAME.Value
end

local function FetchVersionNumber()
	return game.ReplicatedStorage:WaitForChild("Values").GAME_VERSION_NUMBER.Value
end

function Intro.SetVersionMain()
	PlayerGui.MainMenu.VersionFrame.VersionName.Text = FetchVersionName()
	Player.MainMenu.VersionFrame.VersionNumber.Text = FetchVersionNumber()
	
	warn("Set Game Version: "..FetchVersionName()..FetchVersionNumber())
end

local function FadeInElement(element, property)
	if not element then print(element, "is not a ui element") return end
	if not property then print(property, "is not a ui property") return end
	for i = 1,0,-0.05 do
		element[property] = i
		task.wait(0.001)
	end
end

local function FadeOutElement(element,property)
	if not element then print(element, "is not a ui element") return end
	if not property then print(property, "is not a ui property") return end
	for i = 0,1,0.04 do
		element[property] = i
		task.wait(0.00001)
	end
end

local function WaitForLoad()
	--Spin the loading logo
	local Loaded = false
	game.ReplicatedStorage.RemoteEvents.DataStoresLoaded.OnClientEvent:Connect(function()
		IntroUI.LoadingFrame.LoadingBarFrame.Title.TextColor3 = Color3.new(1, 1, 1) --WHITE
		IntroUI.LoadingFrame.LoadingBarFrame.Line.TextColor3 = Color3.new(1, 1, 1)
		
		if #Player:FindFirstChild("SlotDataFolder"):GetChildren() > 0 then
			IntroUI.LoadingFrame.LoadingBarFrame.Title.Text = "Initializing Save Slots..."
		else
			IntroUI.LoadingFrame.LoadingBarFrame.Title.Text = "Initializing New Save..."
		end
		Loaded = true
	end)
	
	while Loaded == false do
		IntroUI.LoadingFrame.LoadingSymbol.Rotation += 5
		task.wait(0.01)
	end
end

local function GetTip()
	local Tips = require(script.Tips)
	local RandNum = math.random(1, #Tips)
	
	return tostring(Tips[RandNum])
end


function Intro.StartIntro()
	CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	IntroUI.IntroFrame.Visible = true
	---------------------------------------------------[Studio Logos]---------------------------------------------------------
	--Check for datastores loading
	
	
	StudioAnimation.Animate()

	
	---------------------------------------------------[CosmoxBlogs Logo]---------------------------------------------------------
	IntroUI.IntroFrame.CosmoxBlogsLogo.Visible = true
	
	FadeInElement(IntroUI.IntroFrame.CosmoxBlogsLogo, "ImageTransparency")
	task.wait(0.03)
	FadeOutElement(IntroUI.IntroFrame.CosmoxBlogsLogo, "ImageTransparency")
	
	task.wait(0.1)
	---------------------------------------------------[Game Logo]---------------------------------------------------------

	IntroUI.LoadingFrame.VersionFrame.Title.Text = FetchVersionName().." "..FetchVersionNumber()

	IntroUI.LoadingFrame.TipFrame.Tip.Text = GetTip()

	--IntroUI.LoadingFrame.Visible = true
	
	
	
	WaitForLoad()
	game.SoundService.Ambience.Menu:Play()
	task.wait(0.9)
	IntroUI.IntroFrame.GameLogo.Visible = true
	local Tween = TweenService:Create(IntroUI.IntroFrame.GameLogo, Tweeninfo, {Position = UDim2.new(0.5,0,0.5,0)})
	
	task.spawn(function()
		FadeInElement(IntroUI.IntroFrame.GameLogo, "TextTransparency")
	end)
	Tween:Play()
	task.wait(0.75)
	FadeOutElement(IntroUI.IntroFrame.GameLogo, "TextTransparency")
	IntroUI.IntroFrame.GameLogo.Visible = false

	IntroUI.IntroFrame.Visible = false
	
	IntroUI.LoadingFrame.LoadingSymbol.Visible = false
	
	
	--IntroUI.LoadingFrame.LoadingBarFrame.Title.TextColor3 = Color3.new(0.333333, 1, 0.498039) --GREEN
	--IntroUI.LoadingFrame.LoadingBarFrame.Line.TextColor3 = Color3.new(0.333333, 1, 0.498039)
	
	--IntroUI.LoadingFrame.LoadingBarFrame.Line.Visible = false
	--local LoadingY = IntroUI.LoadingFrame.LoadingBarFrame.Position.Y
	
	--IntroUI.LoadingFrame.LoadingBarFrame.Title.Text = "Loaded Preliminary Data!"

	--IntroUI.IntroFrame.Visible = false
	--IntroUI.LoadingFrame.Visible = false
	
	CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	Intro.PostIntro()
end

function Intro.PostIntro()
	print("[Intro]: Completed Intro. Proceeding to the main menu...")

	MainMenu.IntroCompleted()
end

return Intro