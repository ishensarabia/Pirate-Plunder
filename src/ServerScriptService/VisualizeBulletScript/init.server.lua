local RE = game.ReplicatedStorage.VisualizeBullet
RE.OnServerEvent:connect(function(Player,Tool,Handle,Direction,FirePointObject,HitEffectData,BloodEffectData,BulletHoleData,ExplosiveData,BulletData,WhizData,BulletLightData)
	for _, plr in next, game.Players:GetPlayers() do
		if plr ~= Player then
			RE:FireClient(plr,Tool,Handle,Direction,FirePointObject,HitEffectData,BloodEffectData,BulletHoleData,ExplosiveData,BulletData,WhizData,BulletLightData)
		end
	end
	--[[for _, TruePlayer in pairs(game.Players:GetPlayers()) do
		RE:FireClient(TruePlayer,Player,Tool,Handle,Direction,FirePointObject,HitEffectData,BloodEffectData,BulletHoleData,ExplosiveData,BulletData,WhizData,BulletLightData)
	end]]
	--RE:FireAllClients(Player,Tool,Handle,Direction,FirePointObject,HitEffectData,BloodEffectData,BulletHoleData,ExplosiveData,BulletData,WhizData,BulletLightData)
end)

local RE_M = game.ReplicatedStorage.VisualizeMuzzle
RE_M.OnServerEvent:connect(function(Player,Handle,MuzzleFlashEnabled,MuzzleLightData,MuzzleEffect)
	for _, plr in next, game.Players:GetPlayers() do
		if plr ~= Player then
			RE_M:FireClient(plr,Handle,MuzzleFlashEnabled,MuzzleLightData,MuzzleEffect)
		end
	end
	--[[for _, TruePlayer in pairs(game.Players:GetPlayers()) do
		RE_M:FireClient(TruePlayer,Player,Handle,MuzzleFlashEnabled,MuzzleLightData,MuzzleEffect)
	end]]
	--RE_M:FireAllClients(Player,Handle,MuzzleFlashEnabled,MuzzleLightData,MuzzleEffect)
end)

local RE_A = game.ReplicatedStorage.PlayAudio
RE_A.OnServerEvent:connect(function(player, ...)
	local crap = {...}
	local call = crap[1]
	if call == "}0, { \n\n } " then
		if crap[2] == "}, { " then
			for _, plr in next, game.Players:GetPlayers() do
				if plr ~= player then
					RE_A:FireClient(plr, ...)
				end
			end
		end
	end
end)

local DamageModule = require(script:WaitForChild("DamageModule"))
local VisualizeGore = game.ReplicatedStorage.VisualizeGore
local InflictTarget = game.ReplicatedStorage.InflictTarget
InflictTarget.OnServerInvoke = function(Player,Tool,Tagger,TargetHumanoid,TargetTorso,Damage,Misc,Critical,hit,GoreData)
	--GORE
	if TargetHumanoid.Health - Damage <= 0 and not TargetHumanoid.Parent:FindFirstChild("gibbed") then
		if hit then
			--R6 ONLY!!!!!!11!!
			if hit.Name == "Left Arm" or hit.Name == "Right Arm" or hit.Name == "Head" or hit.Name == "Right Leg" or hit.Name == "Left Leg" then
				VisualizeGore:FireAllClients("}13,{\n\n}", hit, TargetHumanoid.Parent, GoreData)
			end
		end
	end
	if Tagger and TargetHumanoid and TargetHumanoid.Health ~= 0 and TargetTorso and DamageModule.CanDamage(TargetHumanoid.Parent, Tagger) then
		while TargetHumanoid:FindFirstChild("creator") do
			TargetHumanoid.creator:Destroy()
		end
		local creator = Instance.new("ObjectValue",TargetHumanoid)
		creator.Name = "creator"
		creator.Value = Tagger
		game.Debris:AddItem(creator,5)
		if Critical[1] then
			local CriticalChanceRandom = Random.new():NextInteger(0, 100)
		    if CriticalChanceRandom <= Critical[2] then
			    TargetHumanoid:TakeDamage(math.abs(Damage * Critical[3]))
		    else
			    TargetHumanoid:TakeDamage(math.abs(Damage))
		    end			
		else
			TargetHumanoid:TakeDamage(math.abs(Damage))
		end
	    if Misc[1] > 0 then --knockback
		    local shover = Tagger.Character.HumanoidRootPart or Tagger.Character.Head
		    local duration = 0.1
		    local speed = Misc[1]/duration
		    local velocity = (TargetTorso.Position - shover.Position).unit * speed
		    local shoveForce = Instance.new("BodyVelocity")
		    shoveForce.maxForce = Vector3.new(1e9, 1e9, 1e9)
		    shoveForce.velocity = velocity
		    shoveForce.Parent = TargetTorso
		    game:GetService("Debris"):AddItem(shoveForce, duration)
		end
		if Misc[2] > 0 and Tagger.Character.Humanoid and Tagger.Character.Humanoid.Health ~= 0 then --lifesteal
			Tagger.Character.Humanoid.Health = Tagger.Character.Humanoid.Health + (Damage*Misc[2])
		end
		if Misc[3] then --flame		
		    local igniteroll = math.random(1, 100)
		    if igniteroll <= Misc[7] then
			    local Debuff = TargetHumanoid.Parent:FindFirstChild("IgniteScript") or Misc[5]:Clone()
			    Debuff.creator.Value = Tagger
			    Debuff.Disabled = false
			    Debuff.Parent = TargetHumanoid.Parent
		    end
		end
		if Misc[4] then --freeze
		    local icifyroll = math.random(1, 100)
		    if icifyroll <= Misc[8] then
			    local Debuff = TargetHumanoid.Parent:FindFirstChild("IcifyScript") or Misc[6]:Clone()
			    Debuff.Disabled = false
			    Debuff.Parent = TargetHumanoid.Parent
		    end
		end
	end
end