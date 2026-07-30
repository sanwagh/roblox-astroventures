--[[
    Performance (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → Client
    Parent: Client
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:39:06 (web)
]]

local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local TweenService = game:GetService('TweenService')

local Tweeninfo = TweenInfo.new(0.1,Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0,false,0)

local module = {}
module.__index = module


function module.new()
	local self = setmetatable({},module)
	
	self.Player = game.Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.PerformanceDisplay = self.PlayerGui:WaitForChild("PerformanceUI")
	self.OSD = self.PerformanceDisplay.OSD
	
	self.DisplayFrame = self.PerformanceDisplay.ResultFrame.DisplayFrame
	self.PerformanceDisplaySize = self.PerformanceDisplay.ResultFrame.Size

	self.GPUDisplay = self.DisplayFrame.GPUDisplay
	self.CPUDisplay =  self.DisplayFrame.CPUDisplay
	self.FPSDisplay = self.DisplayFrame.FPSDisplay
	self.IncomingKbDisplay = self.DisplayFrame.IncomingKbDisplay
	self.OutgoingKbDisplay = self.DisplayFrame.OutgoingKbDisplay
	self.MemoryDisplay = self.DisplayFrame.MemoryDisplay
	self.PingDisplay = self.DisplayFrame.PingDisplay
	self.PhysicsDisplay = self.DisplayFrame.PhysicsDisplay
	
	self.FPSTrack = {}
	self.Latency = {}
	self.IncomingKb = {}
	self.OutgoingKb = {}
	self.TotalMemory = {}
	self.PhysicsMemory = {}
	self.ScriptMemory = {}
	self.CPUTime = {}
	self.GPUTime = {}
	self.PhysicsUpdate = {}
	
	self.Interrupt = false
	self.UpdateDebouce = false
	
	self.HEARTBEAT_CONNECTION = nil
	
	return self
end

function module:Init()
	task.spawn(function()
		self.PerformanceDisplay.ResultFrame.DisplayFrame.UsernameDisplay.Text = self.Player.Name
		self:TrackPerformance()
		self.PerformanceDisplay.ResultFrame.CloseBtn.MouseButton1Down:Connect(function()
			self:AnimateUI("Out")
		end)
	end)
	
	task.spawn(function()
		script.Parent.Values.TerrainLoaded:GetPropertyChangedSignal("Value"):Connect(function()
			if script.Parent.Values.TerrainLoaded.Value == false then return end
			print("Wait for 10 seconds")
			
			task.wait(10)
			print("Server Loaded")
			self.Interrupt = true
			print(self.Interrupt)
		end)
	end)
end

function module:TrackPerformance()
	
	self.HEARTBEAT_CONNECTION = RunService.Heartbeat:Connect(function(delta)
		if self.Interrupt == true then 
			self.HEARTBEAT_CONNECTION:Disconnect()

			print("[Performance]: Server loaded. Displaying Data")
			self:AnimateUI("In")
			self:DisplayData()
			return
		end
		
		--FPS
		local FPS = 1/StatsService.FrameTime
		table.insert(self.FPSTrack, FPS)
		
		--NetworkStats
		local Latency = self.Player:GetNetworkPing()
		table.insert(self.Latency, Latency)
		
		local DataSent = StatsService.DataSendKbps
		table.insert(self.OutgoingKb, DataSent)
		
		local DataReceived = StatsService.DataReceiveKbps
		table.insert(self.IncomingKb, DataReceived)
		
		local TotalMem = StatsService:GetTotalMemoryUsageMb()
		table.insert(self.TotalMemory, TotalMem)
		
		local PhysicsMem = StatsService:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.PhysicsParts)
		table.insert(self.PhysicsMemory, PhysicsMem)
		
		local ScriptMem = StatsService:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Script)
		table.insert(self.ScriptMemory, ScriptMem)	
		
		--CPU and GPU
		local CPUTime = StatsService.RenderCPUFrameTime
		table.insert(self.CPUTime, CPUTime)
		
		local GPUTime = StatsService.RenderGPUFrameTime
		table.insert(self.GPUTime, GPUTime)
		
		local PhysicsUpdate = StatsService.PhysicsStepTime
		table.insert(self.PhysicsUpdate, PhysicsUpdate)	
		
		self:UpdateRealTimeData()
	end)
end

function module:UpdateRealTimeData()
	if not self.UpdateDebounce then
		self.UpdateDebounce = true
		
		self.OSD.FPSDisplay.Text = "FPS: " .. math.floor(self.FPSTrack[#self.FPSTrack])
		self.OSD.MemoryUsed.Text = "Mem (Mb): " .. string.format("%.1f", self.TotalMemory[#self.TotalMemory])
		self.OSD.CPUTime.Text = "CPU Time: " .. string.format("%.4f", self.CPUTime[#self.CPUTime])
		self.OSD.GPUTime.Text = "GPU Time: " .. string.format("%.4f", self.GPUTime[#self.GPUTime])
		self.OSD.Physics.Text = "Physics: " .. string.format("%.5f", self.PhysicsUpdate[#self.PhysicsUpdate])
		
		task.wait(0.2)
		self.UpdateDebounce = false
	end
end

local function Format(Val)
	return string.format("%.4f",Val)
end

function module:DisplayData()
	--GPU Display
	local Calc = self:GetCalc(self.GPUTime)
	
	self.GPUDisplay.AverageGPUTime.Text = "Avg: "..tostring(Format(Calc[1]))
	self.GPUDisplay.MaxGPUTime.Text = "Max: "..tostring(Format(Calc[2]))
	self.GPUDisplay.MinGPUTime.Text = "Min: "..tostring(Format(Calc[3]))

	--CPU Display
	Calc = self:GetCalc(self.CPUTime)

	self.CPUDisplay.AverageCPUTime.Text = "Avg: "..tostring(Format(Calc[1]))
	self.CPUDisplay.MaxCPUTime.Text = "Max: "..tostring(Format(Calc[2]))
	self.CPUDisplay.MinCPUTime.Text = "Min: "..tostring(Format(Calc[3]))
	
	--FPS Display
	Calc = self:GetCalc(self.FPSTrack)

	self.FPSDisplay.AverageFPS.Text = "Avg: "..tostring(Format(Calc[1]))
	self.FPSDisplay.MaxFPS.Text = "Max: "..tostring(Format(Calc[2]))
	self.FPSDisplay.MinFPS.Text = "Min: "..tostring(Format(Calc[3]))
	
	--Incoming Kb Display
	Calc = self:GetCalc(self.IncomingKb)


	self.IncomingKbDisplay.AverageIncomingKb.Text = "Avg: "..tostring(Format(Calc[1]))
	self.IncomingKbDisplay.MaxIncomingKb.Text = "Max: "..tostring(Format(Calc[2]))
	self.IncomingKbDisplay.MinIncomingKb.Text = "Min: "..tostring(Format(Calc[3]))
	
	--Outgoing Kb Display
	Calc = self:GetCalc(self.OutgoingKb)


	self.OutgoingKbDisplay.AverageOutgoingKb.Text = "Avg: "..tostring(Format(Calc[1]))
	self.OutgoingKbDisplay.MaxOutgoingKb.Text = "Max: "..tostring(Format(Calc[2]))
	self.OutgoingKbDisplay.MinOutgoingKb.Text = "Min: "..tostring(Format(Calc[3]))
	
	--Ping Display
	Calc = self:GetCalc(self.Latency)

	self.PingDisplay.AveragePing.Text = "Avg: "..tostring(Format(Calc[1]))
	self.PingDisplay.MaxPing.Text = "Max: "..tostring(Format(Calc[2]))
	self.PingDisplay.MinPing.Text = "Min: "..tostring(Format(Calc[3]))
	
	--Physics Display
	Calc = self:GetCalc(self.PhysicsUpdate)

	self.PhysicsDisplay.AveragePhysicsUpdate.Text = "Avg: "..tostring(Format(Calc[1]))
	self.PhysicsDisplay.MaxPhysicsUpdate.Text = "Max: "..tostring(Format(Calc[2]))
	self.PhysicsDisplay.MinPhysicsUpdate.Text = "Min: "..tostring(Format(Calc[3]))
	
	--Memory Display
	Calc = self:GetCalc(self.TotalMemory)
	
	self.MemoryDisplay.AverageTotalMemory.Text = "Avg: "..tostring(Format(Calc[1]))
	self.MemoryDisplay.MaxTotalMemory.Text = "Max: "..tostring(Format(Calc[2]))
	self.MemoryDisplay.MinTotalMemory.Text = "Min: "..tostring(Format(Calc[3]))
	
	Calc = self:GetCalc(self.PhysicsMemory)
	
	self.MemoryDisplay.AveragePhysicsMemory.Text = "Avg: "..tostring(Format(Calc[1]))
	self.MemoryDisplay.MaxPhysicsMemory.Text = "Max: "..tostring(Format(Calc[2]))
	self.MemoryDisplay.MinPhysicsMemory.Text = "Min: "..tostring(Format(Calc[3]))
	
end

function module:GetCalc(Table)
	local Data = {}
	print(Table)
	--Average Calculation
	
	local Total = 0
	for i,v in pairs(Table) do
		if v == math.huge then continue end
		
		Total += tonumber(v)
	end
	
	local Average = (Total)/#Table
	table.insert(Data, Average)
	
	--Max Calculation
	local Max = 0
	for i,v in pairs(Table) do
		if v == math.huge then continue end
		
		if v > Max then
			Max = v
		end
	end
	table.insert(Data, Max)
	
	--Min Calulation
	local Min = math.huge
	
	for i,v in pairs(Table) do
		if v < Min then
			Min = v
		end
	end
	table.insert(Data, Min)
	return Data
end

function module:AnimateUI(Direction)
	if Direction == "In" then
		self.OSD.Visible = false
		self.PerformanceDisplay.ResultFrame.Visible = true
		self.PerformanceDisplay.ResultFrame.Size = UDim2.new(0,0,0,0)
		local Tween = TweenService:Create(self.PerformanceDisplay.ResultFrame, Tweeninfo, {Size = UDim2.new(1,1,1,1)})
		
		Tween:Play()
		Tween.Completed:Wait()

	elseif Direction == "Out" then
		self.OSD.Visible = true
		local Tween = TweenService:Create(self.PerformanceDisplay.ResultFrame, Tweeninfo, {Size = UDim2.new(0,0,0,0)})

		Tween:Play()
		Tween.Completed:Wait()
		
		self.PerformanceDisplay.ResultFrame.Visible = false
	end
end

return module
