local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Class
local Chest = require(Package.Chest)

--Services
local CollectionService = game:GetService("CollectionService")

-- local HomeBase = Object.new("HomeBase")
local HomeBase = Object.newExtends("HomeBase",Chest)

--Collection
local HomeBases = {}
function HomeBase:GetTeam()
	return self.Team
end

function HomeBase:GetBase(team)
	for index, HomeBase in pairs(HomeBases) do
		if HomeBase:GetTeam() == team then
			return HomeBase
		end
	end
end

function HomeBase.new(plate,team)
	-- local obj = HomeBase:make()
	local obj = HomeBase:super()
	obj.Team = team
	obj.Plate = plate

	obj.Plate.Touched:Connect(function(part)
		print("Plate touched")
		HomeBase:ClaimPoints(part,team)
	end)
	return obj
end

function HomeBase:ClaimPoints(part,team)
	local player = game.Players:GetPlayerFromCharacter(part.Parent)

	if player then
		if player:FindFirstChild("HasChest") then
			local Chest = self:GetChest(player.HasChest.Value)
			local HomeBaseTouched = self:GetBase(team)

			if Chest:GetTeam() ~= player.Team.Name and HomeBaseTouched:GetTeam() == player.Team.Name then
				
				player.Character:FindFirstChild(player.HasChest.Value):Destroy()
				game.ReplicatedStorage.Common.GameValues:FindFirstChild(player.Team.Name .. "Score").Value += 1
				player.HasChest:Destroy()

				for index, animationTrack in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
					animationTrack:Stop()
				end

				for i, tool in pairs(game.StarterPack:GetChildren()) do
					tool:Clone().Parent = player.Backpack
				end
				
				Chest:RespawnChest()
			end
		end
	end


end

function HomeBase:InitializeObject()
	for index, homeBase in pairs(CollectionService:GetTagged("HomeBase")) do
		local NewHomeBase = HomeBase.new(homeBase,homeBase.Team.Value)
		table.insert(HomeBases,NewHomeBase)
	end
end

return HomeBase