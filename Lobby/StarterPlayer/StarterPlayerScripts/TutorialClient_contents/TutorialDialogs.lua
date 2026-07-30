--[[
    TutorialDialogs (ModuleScript)
    Path: StarterPlayer → StarterPlayerScripts → TutorialClient
    Parent: TutorialClient
    Properties:
        Disabled: false
    Exported: 2026-07-30 17:35:34 (web)
]]

local Dialogs = {
	-- [Speaker/Stage] = ["Text"]
	
	[1] = [[Hello, I am <font color="#00ffff" >TITAN</font> your assistant who will help you throughout the entirety of your contract with us. Think of me as your mission control - keeping you safe, on track and making sure you don't end up as  space debris]],
	
	[2] =  [[Alright, let's get you started. Head over to the mission display - this is where you will see all of your missions. In the future, this will be your go-to for all mission selection]],
	
	[3] = [[Open the mission list and select your first mission. Don't worry I will be guiding you through this one. 
	To keep things simple, I have made it so that it is the only one you can see.
	]],
	
	--After the player opens the missions list
	[4] = [[Now, here you will be able to select any mission you want. Click on 'More Details'. You will see the details of the mission on the right including the tools and equipments needed for the mission which can be fetched from the Storage Room.]],
	
	[5] = [[Select the mission and accept it to begin. You can hide the tutorial GUI by pressing that button in the top right of the tutorial GUI. 
	]],
	
	-- Player selects the mission,
	[6] = [[Great, now that you're familiar with the mission selection, lets proceed towards the tools you will be needing for this mission. ]],
	
	[7] = [[I have just been updated that you don't need to take any tools for this mission. You will be given the tools when you reach the planet.]],
	
	--Tween cam,
	[8] = [[Anyways, you can get those tools from the storage room over here at Bay 2. Head in there if you want.]],
	
	[9] = [[Let's proceed to the fun part of the mission. Use the stairs to go up to Launchpad 3 located at the end of the hallway and open the doors.]],
	
	-- When the player opens the doors,
	[10] = [[Theres the spaceship you will be using for travelling short distances. You will later be required to refuel and repair the ship as needed.]],
	
	[11] = [[Go into the launch control on your right and turn on all of those switches to initialize our flight]],
	
	-- Once all of them are on,
	[12] = [[Now, go into the spaceship and turn it on. This will be the last time you'll be hearing from me for now. \n See you on the planet!]]
}

return Dialogs