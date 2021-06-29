local TeamsService = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local balanceTeamsEvent = Instance.new("BindableEvent")
balanceTeamsEvent.Name = "BalanceTeamsEvent"
balanceTeamsEvent.Parent = ReplicatedStorage
 
local friendGroups = {}
 
-- Merge all mutual friend groups into one
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
 
-- When players join the game, determine the correct team to join
local function assignInitialTeam(player, group)
	-- Check if the player belongs in a group and the group isn't larger than a fair team size
	if group and #group < game.Players.MaxPlayers / 2 then
		player.Team = group[1].Team
	else
		local teams = TeamsService:GetTeams()
		table.sort(teams, function(a, b) return #a:GetPlayers() < #b:GetPlayers() end)
		--Check to don't assing the initial team to be lobby
		if teams[1].Name ~= "Lobby" then
			player.Team = teams[1]
		else
			player.Team = teams[2]	
		end
	end
end
 
-- Group friends to keep them on the same team
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
 
-- Clean up groups when a player leaves the game
local function removeFromGroup(player)
	-- Loop through the friend groups to find the player
	for groupIndex, group in ipairs(friendGroups) do
		for userIndex, user in ipairs(group) do
			if user.Name == player.Name then
				-- Remove them from whatever group they exist in
				friendGroups[groupIndex][userIndex] = nil
				-- If the group is empty, remove it
				if #friendGroups[groupIndex] == 0 then
					friendGroups[groupIndex] = nil
				end
			end
		end
	end
end
 
local function balanceTeams()
	local teams = TeamsService:GetTeams()
 
	-- Sort the groups so that larger groups are first
	table.sort(friendGroups, function(a, b) return #a > #b end)
 
	-- Iterate through friend groups (already sorted from largest to smallest)
	for i = 1, #friendGroups do
		-- If the group is too big, split them into both teams
		if (#friendGroups[i] > game.Players.MaxPlayers / 2) then
			for _, player in pairs(friendGroups[i]) do
				table.sort(teams, function(a, b) return #a:GetPlayers() < #b:GetPlayers() end)
				player.Team = teams[1]
			end
		else
			-- Sort the list of teams to have the smallest team first
			table.sort(teams, function(a, b) return #a:GetPlayers() < #b:GetPlayers() end)
			local groupTeam = teams[1]
 
			-- Place everyone in the group on the same team
			for _, player in pairs(friendGroups[i]) do
				player.Team = groupTeam
			end
		end
	end
end
 
-- Connect "PlayerRemoving" event to the "removeFromGroup()" function
game.Players.PlayerRemoving:Connect(removeFromGroup)
 
-- Connect "PlayerAdded" events to the "groupFriends()" function
-- game.Players.PlayerAdded:Connect(groupFriends)
 
balanceTeamsEvent.Event:Connect(balanceTeams)