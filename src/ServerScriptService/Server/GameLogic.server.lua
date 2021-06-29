local Round = require(game.ServerScriptService.Server:WaitForChild("Modules").RoundModule)
local RoundConfiguration = game.ServerScriptService.Server.Configurations.Round
local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")
local roundSystemRemotes= game.ReplicatedStorage.Common.RoundSystem.Remotes

-- Round variable	
local roundStarted = false
local timeToJoin = RoundConfiguration.TimeToJoin.Value

local function PlayerJoinedBattle(player)
	local inBattle = Instance.new("BoolValue",player)
	inBattle.Value = true
	inBattle.Name = "InBattle"
end

local Boat = require(game.ReplicatedStorage.Common.OOP.Boat)



roundSystemRemotes.JoinBattle.OnServerEvent:Connect(PlayerJoinedBattle)


----------------------------------------------------------------Game Loop --------------------------------
while wait() do
	wait(1)
	-- repeat
	--     local availablePlayers = {}
	--     for i, plr in pairs(game.Players:GetPlayers()) do
	-- 	    if  plr:FindFirstChild("InBattle") then
	-- 		    table.insert(availablePlayers,plr)
	-- 	    end
	--     end

	-- 	status.Value = "A battle is about to start would you like to join? (" .. #availablePlayers .. "/" ..  RoundConfiguration.MaxPlayers.Value .. ")".. "\nTime left to join: " .. timeToJoin .. " seconds"

	-- 	wait(1)
	-- 	timeToJoin -= 1

	-- until #availablePlayers >= 2 or timeToJoin == 0 
	
	Round.Intermission(13)
	timeToJoin = RoundConfiguration.TimeToJoin.Value


	
			
	local contestants = {}
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if not v:FindFirstChild("InMenu") then
			table.insert(contestants,v)
			print("Added Player "..v.Name.." to contestants")
		end
	end 
	
	-- local chosenKiller
	-- if #contestants > 1 then
	-- 	chosenKiller = Round.ChooseKiller(contestants)
	-- else 
	-- 	chosenKiller = game.ReplicatedStorage.Bots.KillerBot	
	-- end
	
	-- for i, v in pairs(contestants) do
	-- 	-- if v == chosenKiller then
	-- 	-- 	table.remove(contestants,i)
	-- 	-- end	
	-- end
	
	-- for i, v in pairs(contestants) do
	-- 	if v ~= chosenKiller then
	-- 		print("Firing togglecrouch for player: "..v.Name)
	-- 		game.ReplicatedStorage.ToggleCrouch:FireClient(v,true)
	-- 	end	
	-- end
	
	
				
	-- wait(1)
	
	-- if chosenKiller ~= game.ReplicatedStorage.Bots.KillerBot then
	-- 	Round.DressKiller(chosenKiller)
	-- 	Round.TeleportKiller(chosenKiller)
	-- end
	
	
	
	
	Round.TeleportPlayers(contestants)

	
	Round.InsertTag(contestants,"Contestant")
	
	
	
	Round.StartRound(RoundConfiguration.Duration.Value, "Capture the rivals chests")
	
	
	
	contestants = {}
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if not v:FindFirstChild("InMenu") then
			table.insert(contestants,v)
		end
	end 
	
	--if game.Workspace.Lobby:FindFirstChild("Spawns") then
	--	Round.TeleportPlayers(contestants,game.Workspace.Lobby.Spawns:GetChildren())
	--else
	--    warn("Fatal Error: You have not added a Spawns folder into your lobby with the SpawnLocations inside. Please do this to make the script work.")
	--end
	
	
	Round.EndGame()
	Boat:RespawnAllBoats()
	wait(0.5)
end