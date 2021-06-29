local module = {}

module.CanDamage = function(obj, player)
	if obj:FindFirstChild("Humanoid") then
		local p = game.Players:GetPlayerFromCharacter(obj)
		local creator = obj:FindFirstChild("Creator")
		if creator then
			p = creator.Value
		end
		if p then
			if p == player then
				return false
			else
				if p.Neutral or player.Neutral then
					return true
				elseif p.TeamColor ~= player.TeamColor then
					return true
				end
			end
		else
			return true
		end
	end
	return false
end

return module