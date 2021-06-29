local RE = game.ReplicatedStorage:WaitForChild("VisualizeBullet")
local BE_M = script:WaitForChild("VisualizeM")
local RE_M = game.ReplicatedStorage:WaitForChild("VisualizeMuzzle")
local FastCast = require(script:WaitForChild("FastCast"))

local Caster = FastCast.new() --Set the caster values

function numLerp(A, B, Alpha)
	return A + (B - A) * Alpha
end

local function findFirstByClass(dir,class) --Utility function to find the first child of a given class
	for _,i in pairs(dir:children()) do
		if (i:IsA(class)) then return i end
	end
	return nil
end

function MakeImpactFX(Hit, Position, Normal, HitEffectData, BulletHoleData)

   local surfaceCF = CFrame.new(Position, Position + Normal)
			
   if HitEffectData[1] then		
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = surfaceCF
	    Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..HitEffectData[2][math.random(1,#HitEffectData[2])]
		Sound.PlaybackSpeed = Random.new():NextNumber(HitEffectData[3], HitEffectData[4])
		Sound.Volume = HitEffectData[5]
			
		local function spawner2(material)
	        local C = HitEffectData[6][material.Name]:GetChildren()
	        for i=1,#C do
		        if C[i].className == "ParticleEmitter" then
			        local count = 1
			        local Particle = C[i]:Clone()
			        Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
			            count = Particle.EmitCount.Value
		            end
				    if Particle.PartColor.Value then
			            Particle.Color = ColorSequence.new(Hit.Color,Hit.Color)
		            end
			        delay(0.01,function()
			            Particle:Emit(count)
			            game.Debris:AddItem(Particle,Particle.Lifetime.Max)
		            end)
		        end
	        end
	        Sound:Play()
		end
		
        if not HitEffectData[7] then
            if Hit.Material==Enum.Material.Plastic then spawner2(Hit.Material) end
            if Hit.Material==Enum.Material.Slate then spawner2(Hit.Material) end
	        if Hit.Material==Enum.Material.Concrete then spawner2(Hit.Material) end
	        if Hit.Material==Enum.Material.CorrodedMetal then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.DiamondPlate then spawner2(Hit.Material) end
            if Hit.Material==Enum.Material.Foil then spawner2(Hit.Material) end
            if Hit.Material==Enum.Material.Marble then spawner2(Hit.Material) end
	        if Hit.Material==Enum.Material.Granite then	spawner2(Hit.Material) end        
		    if Hit.Material==Enum.Material.Brick then spawner2(Hit.Material) end          
	        if Hit.Material==Enum.Material.Pebble then spawner2(Hit.Material) end          
		    if Hit.Material==Enum.Material.SmoothPlastic then spawner2(Hit.Material) end          
	        if Hit.Material==Enum.Material.Metal then spawner2(Hit.Material) end         
	        if Hit.Material==Enum.Material.Cobblestone then spawner2(Hit.Material) end
	        if Hit.Material==Enum.Material.Neon then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.Wood then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.WoodPlanks then spawner2(Hit.Material) end
	        if Hit.Material==Enum.Material.Glass then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.Grass then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.Sand then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.Fabric then spawner2(Hit.Material) end
		    if Hit.Material==Enum.Material.Ice then spawner2(Hit.Material) end
        else
	        spawner2(HitEffectData[6].Custom)
        end

		game.Debris:AddItem(Attachment,10)				
	end
			
    if BulletHoleData[1] then
		local Hole = Instance.new("Part")
		Hole.Name = "BulletHole"
		Hole.Transparency = 1
		Hole.Anchored = true
		Hole.CanCollide = false
		Hole.FormFactor = "Custom"
		Hole.Size = Vector3.new(1, 1, 0.2)
		Hole.TopSurface = 0
		Hole.BottomSurface = 0
		local Mesh = Instance.new("BlockMesh")
		Mesh.Offset = Vector3.new(0, 0, 0)
		Mesh.Scale = Vector3.new(BulletHoleData[2], BulletHoleData[2], 0)
		Mesh.Parent = Hole
		local Decal = Instance.new("Decal")
		Decal.Face = Enum.NormalId.Front
		Decal.Texture = "rbxassetid://"..BulletHoleData[3][math.random(1,#BulletHoleData[3])]
	    if BulletHoleData[4] then
		    Decal.Color3 = Hit.Color
		end
		Decal.Parent = Hole
		Hole.Parent = workspace.CurrentCamera
		Hole.CFrame = surfaceCF * CFrame.Angles(0, 0, math.random(0, 360))
		if (not Hit.Anchored) then
			local Weld = Instance.new("Weld", Hole)
			Weld.Part0 = Hit
			Weld.Part1 = Hole
		    Weld.C0 = Hit.CFrame:toObjectSpace(surfaceCF * CFrame.Angles(0, 0, math.random(0, 360)))
			Hole.Anchored = false
	    end
		delay(BulletHoleData[5], function()
			if BulletHoleData[5] > 0 then
				local t0 = tick()
				while true do
					local Alpha = math.min((tick() - t0) / BulletHoleData[6], 1)
					Decal.Transparency = numLerp(0, 1, Alpha)
				    if Alpha == 1 then break end
			      	game:GetService("RunService").Heartbeat:wait()
				end
			    Hole:Destroy()
			else
			    Hole:Destroy()
		    end
		end)
    end
end

function MakeBloodFX(Hit, Position, Normal, BloodEffectData)
	
	local surfaceCF = CFrame.new(Position, Position + Normal)
	
    if BloodEffectData[1] then
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = surfaceCF
	    Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..BloodEffectData[2][math.random(1,#BloodEffectData[2])]
		Sound.PlaybackSpeed = Random.new():NextNumber(BloodEffectData[3], BloodEffectData[4])
		Sound.Volume = BloodEffectData[5]
	
		local function spawner3()
	        local C = BloodEffectData[6]:GetChildren()
	        for i=1,#C do
		        if C[i].className == "ParticleEmitter" then
			        local count = 1
			        local Particle = C[i]:Clone()
			        Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
			            count = Particle.EmitCount.Value
		            end
			        delay(0.01,function()
			            Particle:Emit(count)
			            game.Debris:AddItem(Particle,Particle.Lifetime.Max)
		            end)
		        end
	        end
	        Sound:Play()
		end
		
	    spawn(spawner3)
	    game.Debris:AddItem(Attachment,10)
    end	
end

function OnRayHit_Sub2(HitPart, HitPoint, Normal, Material, CosmeticBulletObject, ExplosiveData, HitEffectData, BulletHoleData, BloodEffectData)
	CosmeticBulletObject.Transparency = 1
	--CosmeticBulletObject.CFrame = CosmeticBulletObject.CFrame --This will make cosmetic bullet stop traveling
    game.Debris:addItem(CosmeticBulletObject, 10) --Destroy cosmetic bullet

	local C = CosmeticBulletObject:GetChildren()
	--Disable particle
	for i=1,#C do
	    if C[i].className == "ParticleEmitter" then
            C[i].Enabled = false
	    end
	end
	--Disable whiz sound
	for i=1,#C do
	    if C[i].Name == "Whizzed" then
            C[i].Value = true
	    end
	end
	--Disable ponit light
	for i=1,#C do
	    if C[i].className == "PointLight" then
            C[i]:Destroy()
	    end
    end

	if not ExplosiveData[1] then
	    if HitPart then --Test if we hit something
		    local TargetHumanoid = findFirstByClass(HitPart.Parent,"Humanoid")
		    if TargetHumanoid then
			    MakeBloodFX(HitPart, HitPoint, Normal, BloodEffectData)
		    else
		        MakeImpactFX(HitPart, HitPoint, Normal, HitEffectData, BulletHoleData)
		    end
	    end
    else
	    if ExplosiveData[3] then
			local Sound = Instance.new("Sound")
		    Sound.SoundId = "rbxassetid://"..ExplosiveData[4][math.random(1,#ExplosiveData[4])]
		    Sound.PlaybackSpeed = Random.new():NextNumber(ExplosiveData[5], ExplosiveData[6])
		    Sound.Volume = ExplosiveData[7]
		    Sound.Parent = CosmeticBulletObject
		    Sound:Play()	
		end
		
		local Explosion = Instance.new("Explosion")
		Explosion.BlastRadius = ExplosiveData[2]
		Explosion.BlastPressure = 0
	    Explosion.Position = HitPoint
		Explosion.Parent = workspace.CurrentCamera
		
		if ExplosiveData[8] then
			Explosion.Visible = false
	        local surfaceCF = CFrame.new(HitPoint, HitPoint + Normal)
	
		    local Attachment = Instance.new("Attachment")
		    Attachment.CFrame = surfaceCF
	        Attachment.Parent = workspace.Terrain
	
		    local function spawner4()
	            local C = ExplosiveData[9]:GetChildren()
	            for i=1,#C do
		            if C[i].className == "ParticleEmitter" then
			            local count = 1
			            local Particle = C[i]:Clone()
			            Particle.Parent = Attachment
		                if Particle:FindFirstChild("EmitCount") then
			                count = Particle.EmitCount.Value
		                end
			            delay(0.01,function()
			                Particle:Emit(count)
			                game.Debris:AddItem(Particle,Particle.Lifetime.Max)
		                end)
		            end
	            end
		    end
		
	        spawn(spawner4)
	        game.Debris:AddItem(Attachment,10)
	    end	
		
	end
end

function VisualizeBullet(Tool,Handle,Direction,FirePointObject,HitEffectData,BloodEffectData,BulletHoleData,ExplosiveData,BulletData,WhizData,BulletLightData)
	if Handle then
		Caster.Gravity = BulletData[9]
        Caster.ExtraForce = Vector3.new(BulletData[10].X, BulletData[10].Y, BulletData[10].Z)

	    --UPDATE V6: Proper bullet velocity!
	    --Requested by https://www.roblox.com/users/898618/profile/
	    --We need to make sure the bullet inherits the velocity of the gun as it fires, just like in real life.
	    local HumanoidRootPart = Tool.Parent:WaitForChild("HumanoidRootPart", 1)	--Add a timeout to this.
	    local MyMovementSpeed = HumanoidRootPart.Velocity							--To do: It may be better to get this value on the clientside since the server will see this value differently due to ping and such.
	    local ModifiedBulletSpeed = (Direction * BulletData[8]) + MyMovementSpeed	--We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.
			
		--Make a base cosmetic bullet object. This will be cloned every time we fire off a ray
        local CosmeticBullet = Instance.new("Part")
        CosmeticBullet.Name = "Bullet"
        CosmeticBullet.Material = BulletData[14]
        CosmeticBullet.Color = BulletData[12]
        CosmeticBullet.CanCollide = false
        CosmeticBullet.Anchored = true
        CosmeticBullet.Size = Vector3.new(BulletData[11].X, BulletData[11].Y, BulletData[11].Z)
        CosmeticBullet.Transparency = BulletData[13]
        CosmeticBullet.Shape = BulletData[15]

        if BulletData[16] then
	        local BulletMesh = Instance.new("SpecialMesh")
	        BulletMesh.Scale = Vector3.new(BulletData[19].X, BulletData[19].Y, BulletData[19].Z)
	        BulletMesh.MeshId = "rbxassetid://"..BulletData[17]
	        BulletMesh.TextureId = "rbxassetid://"..BulletData[18]
	        BulletMesh.MeshType = "FileMesh"
	        BulletMesh.Parent = CosmeticBullet
        end
           
	    --Prepare a new cosmetic bullet
	    local Bullet = CosmeticBullet:Clone()
	    Bullet.CFrame = CFrame.new(FirePointObject.WorldPosition, FirePointObject.WorldPosition + Direction)
	    Bullet.Parent = workspace.CurrentCamera
	
	    --[[if WhizData[1] then
		    local Tagger = game.Players:GetPlayerFromCharacter(Tool.Parent)
	        local Debuff = Tool.GunScript_Server:FindFirstChild("WhizScript"):Clone()
	        local creator = Instance.new("ObjectValue",Debuff)
	        creator.Name = "creator"
	        creator.Value = Tagger
            Debuff.Parent = Bullet
            Debuff.Disabled = false
	    end]]
	
		--[[if WhizData[1] then				
		    local BulletWhiz = script.WhizSound:Clone()    
		    BulletWhiz.SoundId = "rbxassetid://"..WhizData[2][math.random(1,#WhizData[2])]
		    BulletWhiz.Volume = WhizData[3]
		    BulletWhiz.PlaybackSpeed = Random.new():NextNumber(WhizData[4], WhizData[5])
		    BulletWhiz.Parent = Bullet
		    BulletWhiz:Play()				
		end]]
		
		local isWhizzed = Instance.new("BoolValue")
		isWhizzed.Name = "Whizzed"
		isWhizzed.Value = false
		isWhizzed.Parent = Bullet

        if BulletLightData[1] then
	        local Light = Instance.new("PointLight")
	        Light.Brightness = BulletLightData[2]
	        Light.Color = BulletLightData[3]
	        Light.Enabled = true
	        Light.Range = BulletLightData[4]
	        Light.Shadows = BulletLightData[5]
	        Light.Parent = Bullet
        end
	
	    if BulletData[1] then
	        local A0 = Instance.new("Attachment", Bullet)
	        A0.Position = Vector3.new(BulletData[2].X, BulletData[2].Y, BulletData[2].Z)
	        A0.Name = "Attachment0"
	        local A1 = Instance.new("Attachment", Bullet)
	        A1.Position = Vector3.new(BulletData[3].X, BulletData[3].Y, BulletData[3].Z)
	        A1.Name = "Attachment1"
	
	        local C = BulletData[4]:GetChildren()
	        for i=1,#C do
		        if C[i].className == "Trail" then
		            local count = 1
		            local Tracer = C[i]:Clone()
		            Tracer.Attachment0 = A0
		            Tracer.Attachment1 = A1
		            Tracer.Parent = Bullet
		        end
	        end
	    end
	
	    if BulletData[5] then
	        local C = BulletData[6]:GetChildren()
	        for i=1,#C do
		        if C[i].className == "ParticleEmitter" then
		            local Particle = C[i]:Clone()
		            Particle.Parent = Bullet
                    Particle.Enabled = true
		        end
	        end
	    end	
	
	    Caster:FireWithBlacklist(FirePointObject.WorldPosition, Direction * BulletData[7], ModifiedBulletSpeed, {Handle, Tool.Parent, workspace.CurrentCamera}, Bullet, WhizData)

        function OnRayHit_Sub(HitPart, HitPoint, Normal, Material, CosmeticBulletObject)
            OnRayHit_Sub2(HitPart,
	                HitPoint,
	                Normal,
	                Material,
	                CosmeticBulletObject,
	                {ExplosiveData[1], ExplosiveData[2], ExplosiveData[3], ExplosiveData[4], ExplosiveData[5], ExplosiveData[6], ExplosiveData[7], ExplosiveData[8], ExplosiveData[9]},
	                {HitEffectData[1], HitEffectData[2], HitEffectData[3], HitEffectData[4], HitEffectData[5], HitEffectData[6], HitEffectData[7]},
	                {BulletHoleData[1], BulletHoleData[2], BulletHoleData[3], BulletHoleData[4], BulletHoleData[5], BulletHoleData[6]},
	                {BloodEffectData[1], BloodEffectData[2], BloodEffectData[3], BloodEffectData[4], BloodEffectData[5], BloodEffectData[6]})
        end
	end
end

function VisualizeMuzzle(Handle,MuzzleFlashEnabled,MuzzleLightData,MuzzleEffect)
	if Handle then
        local function spawner1()				
	        local C = MuzzleEffect:GetChildren()
	        for i=1,#C do
		        if C[i].className == "ParticleEmitter" then
			        local count = 1
			        local Particle = C[i]:Clone()
			        Particle.Parent = Handle:FindFirstChild("GunMuzzlePoint")
		            if Particle:FindFirstChild("EmitCount") then
			            count = Particle.EmitCount.Value
		            end
			        delay(0.01,function()
			            Particle:Emit(count)
			            game.Debris:AddItem(Particle,Particle.Lifetime.Max)
	     	        end)
		        end
	        end					
        end
	
       	if MuzzleFlashEnabled then		
	        spawn(spawner1)
       	end
		
      	if MuzzleLightData[1] then
	        local Light = Instance.new("PointLight")
	        Light.Brightness = MuzzleLightData[2]
	        Light.Color = MuzzleLightData[3]
	        Light.Enabled = true
	        Light.Range = MuzzleLightData[4]
	        Light.Shadows = MuzzleLightData[5]
	        Light.Parent = Handle:FindFirstChild("GunMuzzlePoint")
            game.Debris:addItem(Light,MuzzleLightData[6])
        end
	end
end

local camera = workspace.CurrentCamera
local RE_A = game.ReplicatedStorage:WaitForChild("PlayAudio")
local BE_A = script:WaitForChild("Play")
local distantshots =  {"rbxassetid://177174605"} --rbxassetid://461803957",
function PlayAudio(audio)
	local s = Instance.new("Sound")
	s.SoundId = audio.SoundId
	s.EmitterSize = audio.EmitterSize or 70
	s.Volume = audio.Volume or 1
	s.PlaybackSpeed = audio.Pitch or 1
	local a = camera
	local t = nil
	local ac = false
	if audio.Position then
		if typeof(audio.Position) == "Vector3" then
			a = Instance.new("Attachment", workspace.Terrain)
			a.CFrame = CFrame.new(audio.Position)
			ac = true
		else
			a = audio.Position
		end
	end
	s.Parent = a
	if audio.Effects then
		local distance = math.min(1000, ((a:IsA"Attachment" and a.WorldPosition or a.CFrame.p) - camera.CFrame.p).magnitude)
		if distance > 200 then
			t = Instance.new("Sound", a)
			t.SoundId = distantshots[math.random(#distantshots)] 
			t.Volume = 1.5
			t.EmitterSize = 100
			
			game.Debris:AddItem(t, 3)
		
			s.Pitch = 1 - distance/2000
			local rev = Instance.new("ReverbSoundEffect", s)
			rev.DryLevel = 0
			rev.WetLevel = (distance/1000) * -20
			
			local eq = Instance.new("EqualizerSoundEffect", s)
			eq.LowGain = (distance/1000) * -15
			eq.MidGain = (distance/1000) * 5
			eq.HighGain = 0
		end
	end
	repeat wait() until s.TimeLength > 0
	s:Play()
	if t then
		t:Play()
	end
	
	game.Debris:AddItem(s, s.TimeLength)
	if ac then
		game.Debris:AddItem(a, s.TimeLength)
	end
	if audio.Replicate then
		audio.Replicate = false
		RE_A:FireServer("}0, { \n\n } ","}, { ", audio)
	end
end
BE_A.Event:connect(function(self)
	PlayAudio(self)
end)
RE_A.OnClientEvent:connect(function(...)
	local crap = {...}
	if crap[1] == "}0, { \n\n } " then
		if crap[2] == "}, { " then
			PlayAudio(crap[3])
		end
	end
end)

local OnWhiz = function(whizTable)	
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://"..whizTable[2][math.random(1,#whizTable[2])]
	s.Volume = whizTable[3]
	s.PlaybackSpeed = Random.new():NextNumber(whizTable[4], whizTable[5])
	game:service"SoundService":PlayLocalSound(s)
end

function OnRayHit(HitPart, HitPoint, Normal, Material, CosmeticBulletObject)
	OnRayHit_Sub(HitPart, HitPoint, Normal, Material, CosmeticBulletObject)
end

function OnRayUpdated(CastOrigin, SegmentOrigin, SegmentDirection, Length, CosmeticBulletObject, WhizTable)
    local BulletLength = CosmeticBulletObject.Size.Z / 2 --This is used to move the bullet to the right spot based on a CFrame offset
	CosmeticBulletObject.CFrame = CFrame.new(SegmentOrigin, SegmentOrigin + SegmentDirection) * CFrame.new(0, 0, -(Length - BulletLength))
	if WhizTable[1] then
		if not CosmeticBulletObject:FindFirstChild("Whizzed").Value then	
			local mag = (camera.CFrame.p - CosmeticBulletObject.Position).magnitude		
			if mag < WhizTable[6] then
				OnWhiz(WhizTable)
				CosmeticBulletObject:FindFirstChild("Whizzed").Value = true
			end
		end
	end
end

RE.OnClientEvent:connect(VisualizeBullet)
BE_M.Event:connect(VisualizeMuzzle)
RE_M.OnClientEvent:connect(VisualizeMuzzle)
Caster.LengthChanged:Connect(OnRayUpdated)
Caster.RayHit:Connect(OnRayHit)