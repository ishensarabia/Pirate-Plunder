local module = {}
local MarketplaceService = game:GetService("MarketplaceService")
--Team scores
local piratesScore = game.ReplicatedStorage.Common.GameValues.PiratesScore
local sailorsScore = game.ReplicatedStorage.Common.GameValues.SailorsScore
local requiredScore = game.ReplicatedStorage.Common.GameValues.RequiredChestsToWin
local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")
local Teams = game:GetService("Teams")


function module.Intermission(length)
	local friendGroups = {}
	for i = length,0,-1 do
		status.Value = "Next battle starts in "..i.." seconds"
		wait(1)
	end
	local function assignInitialTeam(player, group)
		-- Check if the player belongs in a group and the group isn't larger than a fair team size
		if group and #group < game.Players.MaxPlayers / 2 then
			player.Team = group[1].Team
		else
			local teams = game:GetService("Teams"):GetTeams()
			table.sort(teams, function(a, b) return #a:GetPlayers() < #b:GetPlayers() end)
			--Check to don't assing the initial team to be lobby
			if teams[1].Name ~= "Lobby" then
				player.Team = teams[1]
			else
				player.Team = teams[2]	
			end
		end
	end
	local function mergeGroups(groups)
		-- Add other group members to the first group
		for i = 2, #groups do
			for _, user in pairs(friendGroups[groups[i]]) do
				table.insert(friendGroups[groups[1]], user)
			end
			-- Remove leftover groups that were merged
			table.remove(friendGroups, groups[i])
		end
	 
		return groups[1]
	end
	local function groupFriends(player)
		local mutualGroups = {}
	 
		-- Iterate through friend groups
		for groupIndex, group in ipairs(friendGroups) do
			-- Iterate through friends found in groups
			for _, user in ipairs(group) do
				-- Group mutual friends together
				if player:IsFriendsWith(user.UserId) then
					if (mutualGroups[group] == nil) then
						table.insert(mutualGroups, groupIndex)
					end
				end
			end
		end
	 
		if #mutualGroups > 0 then
			local groupIndex = mutualGroups[1]
	 
			-- If the player has multiple groups of friends playing, merge into one group
			if #mutualGroups > 1 then
				groupIndex = mergeGroups(mutualGroups)
			end
	 
			table.insert(friendGroups[groupIndex], player)
			assignInitialTeam(player, friendGroups[groupIndex])
		else
			table.insert(friendGroups, {player})
			assignInitialTeam(player)
		end
	end
	for index, player in pairs(game.Players:GetPlayers()) do
		groupFriends(player)
	end
end

function module.TeleportPlayers(players)
	-- 'players' will be a Table containing all contestants' player objects
	-- eg {game.Players.L00F1, game.Players.Talorgamer1, game.Players.JKOKIplaysyt}

	for i, player in pairs(players) do
		if player.Character then
			local character = player.Character

			player.Character.Humanoid.Sit = false

			repeat
				player.Character.Humanoid.Sit = false
				wait()
			until character.Humanoid.Sit == false

			if character:FindFirstChild("HumanoidRootPart") then
				
				local teamSpawns =  workspace:FindFirstChild(player.Team.Name .. "Spawns"):GetChildren()
				player.Character.Humanoid.WalkSpeed = 16

				local rand = Random.new()
				player.Character.HumanoidRootPart.CFrame = teamSpawns[rand:NextInteger(1,#teamSpawns)].CFrame + Vector3.new(0,10,0)
	
			end
		end
	end

end



local function toMS(s)
	return ("%02i:%02i"):format(s/60%60, s%60)
end

function module.StartRound(length,roundMessage) -- length (in seconds)

	local outcome
	local killerBotReplacementDebounce = false
	local statusDebounce = false

	game.ReplicatedStorage.Common.GameValues.GameInProgress.Value = true

	local sound = Instance.new("Sound",workspace)
	sound.SoundId = "rbxassetid://6702925777"
	sound.RollOffMaxDistance = 10000
	sound:Play()
	spawn(function()
		sound.Ended:Wait()
		sound:Destroy()
	end)



	for i = length,0,-1 do

		if statusDebounce == false then
			status.Value = roundMessage
			statusDebounce = true
			wait(3)
		end

		local contestants = {}


		local Escapees = 0

		for i, player in pairs(game.Players:GetPlayers()) do

			if player:FindFirstChild("Contestant") then
				table.insert(contestants,player)
			end

		end

		status.Value = toMS(i)


		if #contestants == 0 then
			outcome = "Killer-killed-everyone"
			break
		end 

		if i == 0 then
			outcome = "Time-up"
			break
		end
		
		if piratesScore.Value >= requiredScore.Value then
			outcome = "Pirates"
			break
		end	

		if sailorsScore.Value >= requiredScore.Value then
			outcome = "Sailors"
			break
		end	

		wait(1)
	end

	if outcome == "Pirates" then
		status.Value = "Pirates won the match!"
	elseif outcome == "Sailors" then
		status.Value = "Sailors won the match!"
	elseif outcome == "Time-up" then
		if piratesScore.Value == sailorsScore.Value then
			status.Value = "Time up, draw"
			return
		end

		if piratesScore.Value > sailorsScore.Value then
			status.Value = "Time up, pirates won the match"
		else
			status.Value = "Time up, sailors won the match"
		end	
	end 



	wait(5)

end

function module.InsertTag(contestants,tagName)
	for i, player in pairs(contestants) do
		local Tag = Instance.new("StringValue")
		Tag.Name = tagName
		Tag.Parent = player
	end
end



function module.EndGame()

	game.ReplicatedStorage.Common.GameValues.GameInProgress.Value = false
	game.ReplicatedStorage.Common.GameValues.SailorsScore.Value = 0
	game.ReplicatedStorage.Common.GameValues.PiratesScore.Value = 0
	--Re-enable chests
	for i , child in pairs(game.Workspace.PirateChests:GetDescendants()) do
		if child:IsA("Decal") or child:IsA("BasePart") then
			child.Transparency = 0
		end

		if child:IsA("ProximityPrompt") then
			child.Enabled = true
		end	
	end	

	for i , child in pairs(game.Workspace.SailorChests:GetDescendants()) do
		if child:IsA("Decal") or child:IsA("BasePart") then
			child.Transparency = 0
		end

		if child:IsA("ProximityPrompt") then
			child.Enabled = true
		end	
	end	


	for i, player in pairs(game.Players:GetPlayers()) do

	player.Team = Teams.Lobby
	player.Character:MoveTo(workspace.LobbySpawn.Position + Vector3.new(math.random(0,10), 0, math.random(0,10)))


	if player:FindFirstChild("Contestant") then
			player.Contestant:Destroy()
			-- for _, p in pairs(v.Backpack:GetChildren()) do
			-- 	if p:IsA("Tool") then
			-- 		p:Destroy()
			-- 	end
			-- end

			-- for _, p in pairs(v.Character:GetChildren()) do
			-- 	if p:IsA("Tool") then
			-- 		p:Destroy()
			-- 	end
			-- end

		end

	end

end

return module