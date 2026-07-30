--[[
    LoadGame (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → IntroController → UIControllerModule → MainMenu
    Parent: MainMenu
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Player = game.Players.LocalPlayer
local PlayerGui:PlayerGui = Player:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenu")

local PostLoading = require(script.Parent.PostLoading)
local NewGameModule = require(script.Parent.NewGame)

local DeleteDebounce = false

--Connections
local EditBtnConnection = nil
local SaveBtnConnection = nil
local DeleteBtnConnection = nil
local LoadBtnConnection = nil

local LoadGame = {}

function LoadGame.Show()
	--Shows the ui and calls the functionality functions
	LoadGame.DisplayAllSlots()
	MainMenuUI.LoadGameFrame.Visible = true
	MainMenuUI.LoadGameFrame.SlotDisplay:TweenPosition(
		UDim2.new(0.122,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		0.4,
		true
	)
	
	-- TODO Switch to call on button press not call before button press. Causes multiple function instances.
	task.spawn(LoadGame.OnLoadClicked) 
	task.spawn(LoadGame.OnDeleteClicked)
	task.spawn(LoadGame.OnEditClicked)
	
	MainMenuUI.LoadGameFrame.SlotDisplay.NewSlot.MouseButton1Down:Connect(function()
		LoadGame.OnNewGameClicked()
	end)
	MainMenuUI.LoadGameFrame.SlotDisplay.BackBtn.MouseButton1Down:Connect(function()
		LoadGame.OnBackClicked()
	end)
end

local function ClearPreExistingSlotFrameInstances()
	for i,frame in pairs(MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function DisplayData(SlotFrame, slot)
	SlotFrame.CreationDate.Text = "Created On: "..slot.CreationDate.Value
	SlotFrame.LastLoad.Text = "Last Loaded: "..slot.LastLoadDate.Value
	local Difficulty = slot.Difficulty.Value
	
	if Difficulty == "Easy" then
		SlotFrame.Difficulty.TextColor = BrickColor.new(0.333333, 1, 0)
		SlotFrame.Difficulty.Text = Difficulty
	elseif Difficulty == "Normal" then
		SlotFrame.Difficulty.TextColor = BrickColor.new(0.333333, 0.666667, 0)
		SlotFrame.Difficulty.Text = Difficulty
	elseif Difficulty == "Medium" then
		SlotFrame.Difficulty.TextColor = BrickColor.new(1, 1, 0)
		SlotFrame.Difficulty.Text = Difficulty
	elseif Difficulty == "Hard" then
		SlotFrame.Difficulty.TextColor = BrickColor.new(1, 0, 0)
		SlotFrame.Difficulty.Text = Difficulty
	elseif Difficulty == "Survival" then
		SlotFrame.Difficulty.TextColor = BrickColor.new(0.666667, 0, 0)
		SlotFrame.Difficulty.Text = Difficulty
	else
		warn("[LoadGame]: Slot Dificulty Not found - ", Difficulty)
		SlotFrame.Difficulty.Text = "NOT_FOUND!"
	end
end

function LoadGame.DisplayAllSlots()
	ClearPreExistingSlotFrameInstances()
	
	for i,slot in pairs(Player.SlotDataFolder.Slots:GetChildren()) do
		if slot:IsA("Folder") then
			local slotFrame = game.ReplicatedStorage.Gui.Slot:Clone()
			slotFrame.Parent = MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame
			slotFrame.Name = slot.Name
			slotFrame.Values.SlotName.Value = slot.Name
			slotFrame.SlotName.Text = slot.SlotName.Value
			slotFrame.Visible = true
			
			DisplayData(slotFrame, slot)
		end
	end
end

function LoadGame.OnLoadClicked()
	-- Loop through all the slots and check for click on the load btn. Once detected, Fire a remote event and load the player.
	if LoadBtnConnection then LoadBtnConnection:Disconnect() print("[LoadGame]: Disconnected a pre existing connection to LoadBtn") end

	for i, frame in pairs(MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame:GetChildren()) do
		if frame:IsA("Frame") then
			LoadBtnConnection = frame.LoadBtn.MouseButton1Down:Connect(function()
				MainMenuUI.LoadGameFrame.SlotDisplay:TweenPosition(
					UDim2.new(-0.5,0,0.5,0),
					Enum.EasingDirection.In,
					Enum.EasingStyle.Quad,
					0.2,
					true
				)
				game.SoundService.SFX.Click:Play()
				game.ReplicatedStorage.RemoteEvents.SlotChangeRequest:FireServer("Load", frame.Values.SlotName.Value) --[2] = slt_name
				print("[LoadGame]: Sent request to server to load", frame.Name, " for ", Player.Name)
				PostLoading.OnLoaded()
			end)
		end
	end
end

function LoadGame.OnBackClicked()
	game.SoundService.SFX.Click:Play()
	MainMenuUI.LoadGameFrame.SlotDisplay:TweenPosition(
		UDim2.new(-0.5,0,0.5,0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		0.4,
		true
	)
	MainMenuUI.MainMenuFrame.Visible = true
end

local function DeleteConfirmation(slot)
	--Show the Confirmation ui. If yes is clicked, fire a remote event and return true. If no, then return false and close the ui
	-- Call DisplayAllSlots again.
	-- Potential issue: script might get stuck in a deadlock.
	-- Solution: instead of calling the function, delete the slot.
	-- DO NOT DELETE COMMENTS
	if not DeleteDebounce then
		DeleteDebounce = true
		
		local Confirmed = nil
		local GotResult = false
		
		MainMenuUI.LoadGameFrame.DeleteFrame.Visible = true
		
		MainMenuUI.LoadGameFrame.DeleteFrame.Desc.Text = "Are you sure you want to delete "..slot.Name..". This process is irreverable and you will lose all the data"
		
		MainMenuUI.LoadGameFrame.DeleteFrame.CancelBtn.MouseButton1Down:Once(function()
			print("Cancel")
			game.SoundService.SFX.Click:Play()
			MainMenuUI.LoadGameFrame.DeleteFrame.Visible = false

			GotResult = true
			Confirmed = false
		end)

		MainMenuUI.LoadGameFrame.DeleteFrame.DeleteBtn.MouseButton1Down:Once(function()
			print("Delete")
			game.SoundService.SFX.Warning:Play()
			MainMenuUI.LoadGameFrame.DeleteFrame.Visible = false

			GotResult = true
			Confirmed = true
		end)
		while not GotResult do
			task.wait()
		end
		task.wait(0.5)
		DeleteDebounce = false

		return Confirmed
	end
end

function LoadGame.OnDeleteClicked()
	-- Loop through all the slots and check for click on the delete btn. Once detected, Call the DeleteConfirmation func.
	for i,frame in pairs(MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.DeleteBtn.MouseButton1Down:Once(function()
				game.SoundService.SFX.Warning:Play()
				print("[LoadGame]: Player requesting to delete slot ", frame.Name)
				
				if DeleteConfirmation(frame) == true then
					print("[LoadGame]: Sending Request to server to delete ", frame.Name)
					game.ReplicatedStorage.RemoteEvents.SlotChangeRequest:FireServer("Delete", frame.Values.SlotName.Value) --[2] = slt_name
					frame:Destroy()
				else
					print("[LoadGame]: Denied Confirmation on Slot Deletion")
				end
			end)
		end
	end
end

local function GetChangedName()
	return MainMenuUI.LoadGameFrame.EditFrame.SlotName.Text
end

function LoadGame.OnEditClicked()	
	for i,frame in pairs(MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame:GetChildren()) do
		if frame:IsA("Frame") then
			if EditBtnConnection then EditBtnConnection:Disconnect() print("[LoadGame]: Disconnected a pre existing connection to EditBtn") end

			EditBtnConnection = frame.SlotName.EditBtn.MouseButton1Down:Connect(function()
				if SaveBtnConnection then SaveBtnConnection:Disconnect() print("[LoadGame]: Disconnected a pre existing connection to SaveBtn") end
				
				game.SoundService.SFX.Click:Play()
				MainMenuUI.LoadGameFrame.EditFrame.Visible = true
				
				SaveBtnConnection = MainMenuUI.LoadGameFrame.EditFrame.SaveBtn.MouseButton1Down:Once(function()
					local Name = GetChangedName()
					if Name == "" or Name == " " then
						MainMenuUI.LoadGameFrame.EditFrame.Status.Visible = true
						MainMenuUI.LoadGameFrame.EditFrame.Status.Text = "Invalid Name"
						MainMenuUI.LoadGameFrame.EditFrame.Status.TetColor = BrickColor.new(1, 0, 0)    
						
						task.wait(1)
						MainMenuUI.LoadGameFrame.EditFrame.Status.Visible = false

					else
						print("[LoadGame]: Changing name of ", frame.Name, Name,". Requesting server to check name..")
						
						local SlotId = frame.Name
						
						
						
						game.ReplicatedStorage.RemoteEvents.SlotChangeRequest:FireServer("Name", frame.Name, Name)
						MainMenuUI.LoadGameFrame.EditFrame.Status.Visible = true
						MainMenuUI.LoadGameFrame.EditFrame.Status.Text = "Success"
						MainMenuUI.LoadGameFrame.EditFrame.Status.TextColor = BrickColor.new(0, 0.666667, 0)  
						
						local PlayerSlot = Player.SlotDataFolder.Slots:FindFirstChild(SlotId).SlotName.Value
						MainMenuUI.LoadGameFrame.SlotDisplay.SlotFrame:FindFirstChild(SlotId).SlotName.Text = PlayerSlot
						
						task.wait(1)
						MainMenuUI.LoadGameFrame.EditFrame.Visible = false
						MainMenuUI.LoadGameFrame.EditFrame.SlotName.Text = ""
						MainMenuUI.LoadGameFrame.EditFrame.Status.Visible = false
					end 
				end)
				
				MainMenuUI.LoadGameFrame.EditFrame.CancelBtn.MouseButton1Down:Connect(function()
					game.SoundService.SFX.Click:Play()
					MainMenuUI.LoadGameFrame.EditFrame.Visible = false
				end)
			end)
		end
	end
end

function LoadGame.OnNewGameClicked()
	
		game.SoundService.SFX.Click:Play()
		print("[LoadGame]: Player clicked the new game btn...")
		NewGameModule.Show()
end

return LoadGame