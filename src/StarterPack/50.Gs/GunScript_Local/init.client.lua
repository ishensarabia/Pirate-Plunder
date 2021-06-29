local UserInputService = game:GetService("UserInputService")
local InitialSensitivity = UserInputService.MouseDeltaSensitivity
local TweeningService = game:GetService("TweenService")
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")
local Module = require(Tool:WaitForChild("Setting"))
local GunScript_Server = Tool:WaitForChild("GunScript_Server")
local ChangeMagAndAmmo = GunScript_Server:WaitForChild("ChangeMagAndAmmo")
local VisualizeBullet = game.ReplicatedStorage:WaitForChild("VisualizeBullet")
local VisualizeMuzzle = game.ReplicatedStorage:WaitForChild("VisualizeMuzzle")
local MarkerEvent = script:WaitForChild("MarkerEvent")
local MagValue = GunScript_Server:WaitForChild("Mag")
local AmmoValue = GunScript_Server:WaitForChild("Ammo")
local GUI = script:WaitForChild("GunGUI")
local CrosshairModule = require(GUI:WaitForChild("CrosshairModule"))
local CameraModule = require(GUI:WaitForChild("CameraModule"))
local IdleAnim
local FireAnim
local ReloadAnim
local ShotgunClipinAnim
local HoldDownAnim
local EquippedAnim
local Grip2
local Handle2
local HandleToFire = Handle

local spring = require(script.SpringModule)
local oldPosition = Vector2.new()

local self={}

-- Scope shake
self.scope = spring.new(Vector3.new(0,200,0))
self.scope.s = Module.ScopeSwaySpeed
self.scope.d = Module.ScopeSwayDamper

--Push
self.knockback = spring.new(Vector3.new())
self.knockback.s = Module.ScopeKnockbackSpeed
self.knockback.d = Module.ScopeKnockbackDamper

-- Dual welding

if Module.DualEnabled then
	Handle2 = Tool:WaitForChild("Handle2",2)
	if Handle2 == nil and Module.DualEnabled then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

local Equipped = false
local Enabled = true
local Down = false
local HoldDown = false
local Reloading = false
local AimDown = false
local Scoping = false
local Mag = MagValue.Value
local Ammo = AmmoValue.Value
local MaxAmmo = Module.MaxAmmo

if Module.IdleAnimationID ~= nil or Module.DualEnabled then
	IdleAnim = Tool:WaitForChild("IdleAnim")
	IdleAnim = Humanoid:LoadAnimation(IdleAnim)
end
if Module.FireAnimationID ~= nil then
	FireAnim = Tool:WaitForChild("FireAnim")
	FireAnim = Humanoid:LoadAnimation(FireAnim)
end
if Module.ReloadAnimationID ~= nil then
	ReloadAnim = Tool:WaitForChild("ReloadAnim")
	ReloadAnim = Humanoid:LoadAnimation(ReloadAnim)
end
if Module.ShotgunClipinAnimationID ~= nil then
	ShotgunClipinAnim = Tool:WaitForChild("ShotgunClipinAnim")
	ShotgunClipinAnim = Humanoid:LoadAnimation(ShotgunClipinAnim)
end
if Module.HoldDownAnimationID ~= nil then
	HoldDownAnim = Tool:WaitForChild("HoldDownAnim")
	HoldDownAnim = Humanoid:LoadAnimation(HoldDownAnim)
end
if Module.EquippedAnimationID ~= nil then
	EquippedAnim = Tool:WaitForChild("EquippedAnim")
	EquippedAnim = Humanoid:LoadAnimation(EquippedAnim)
end

function wait(TimeToWait)
	if TimeToWait ~= nil then
		local TotalTime = 0
		TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		while TotalTime < TimeToWait do
			TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		end
	else
		game:GetService("RunService").Heartbeat:wait()
	end
end

function numLerp(A, B, Alpha)
	return A + (B - A) * Alpha
end

function RAND(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end


function CastRay(StartPos,Direction,Length)
	local Hit,EndPos = game.Workspace:FindPartOnRay(Ray.new(StartPos,Direction * Length))
	if Hit then
		if (not Tool.Parent or Hit:IsDescendantOf(Tool.Parent)) or Hit.Transparency > 0.9 then
			return CastRay(EndPos + (Direction * 0.01),Direction,Length - ((StartPos - EndPos).magnitude))
		end
	end
	
	return EndPos
end


local function Get3DPosition(CurrentPosOnScreen)
	local X = CurrentPosOnScreen.X + math.random(-Module.SpreadX * 2, Module.SpreadX * 2) * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
	local Y = CurrentPosOnScreen.Y + math.random(-Module.SpreadY * 2, Module.SpreadY * 2) * (AimDown and 1-Module.SpreadRedutionIS and 1-Module.SpreadRedutionS or 1)
	local InputRay = Camera:ScreenPointToRay(X,Y)
	local EndPos = InputRay.Origin + InputRay.Direction
	return CastRay(Camera.CFrame.p,(EndPos - Camera.CFrame.p).unit,1000)
end

MarkerEvent.Event:connect(function(IsHeadshot)
	pcall(function()
	    if Module.HitmarkerEnabled then
		    if IsHeadshot then
			    GUI.Crosshair.Hitmarker.ImageColor3 = Module.HitmarkerColorHS
                GUI.Crosshair.Hitmarker.ImageTransparency = 0
                TweeningService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(Module.HitmarkerFadeTimeHS, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
	            local markersound = GUI.Crosshair.MarkerSound:Clone()
	            markersound.SoundId = "rbxassetid://"..Module.HitmarkerSoundID[math.random(1,#Module.HitmarkerSoundID)]
	            markersound.PlaybackSpeed = Module.HitmarkerSoundPitchHS
	            markersound.Parent = Player.PlayerGui
	            markersound:Play()
	            game:GetService("Debris"):addItem(markersound,1.15)
		    else
			    GUI.Crosshair.Hitmarker.ImageColor3 = Module.HitmarkerColor
			    GUI.Crosshair.Hitmarker.ImageTransparency = 0
			    TweeningService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(Module.HitmarkerFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
	            local markersound = GUI.Crosshair.MarkerSound:Clone()
	            markersound.SoundId = "rbxassetid://"..Module.HitmarkerSoundID[math.random(1,#Module.HitmarkerSoundID)]
	            markersound.PlaybackSpeed = Module.HitmarkerSoundPitch
	            markersound.Parent = Player.PlayerGui
	            markersound:Play()
	            game:GetService("Debris"):addItem(markersound,1.15)
			end
	    end
	end)
end)

function EjectShell(ShootingHandle)
	if Module.BulletShellEnabled then
		local ShellPos = (ShootingHandle.CFrame * CFrame.new(Module.BulletShellOffset.X,Module.BulletShellOffset.Y,Module.BulletShellOffset.Z)).p
		local Chamber = Instance.new("Part")
		Chamber.Name = "Chamber"
		Chamber.Size = Vector3.new(0.01,0.01,0.01)
		Chamber.Transparency = 1
		Chamber.Anchored = false
		Chamber.CanCollide = false
		Chamber.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Chamber.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		local Weld = Instance.new("Weld",Chamber)
		Weld.Part0 = ShootingHandle
		Weld.Part1 = Chamber
		Weld.C0 = CFrame.new(Module.BulletShellOffset.X,Module.BulletShellOffset.Y,Module.BulletShellOffset.Z)
		Chamber.Position = ShellPos
		Chamber.Parent = workspace.CurrentCamera
		local function spawner()
	        local Shell = Instance.new("Part")
	        Shell.CFrame = Chamber.CFrame * CFrame.fromEulerAnglesXYZ(-5,1,20)
	        Shell.Size = Module.ShellSize
	        Shell.CanCollide = Module.AllowCollide
	        Shell.Name = "Shell"
		    Shell.Velocity = Chamber.CFrame.lookVector * 20 + Vector3.new(math.random(-10,10),20,math.random(-10,10))
	        Shell.RotVelocity = Vector3.new(0,200,0)
	        Shell.Parent = workspace.CurrentCamera
	        local shellmesh = Instance.new("SpecialMesh")
	        shellmesh.Scale = Module.ShellScale
	        shellmesh.MeshId = "rbxassetid://"..Module.ShellMeshID
	        shellmesh.TextureId = "rbxassetid://"..Module.ShellTextureID
	        shellmesh.MeshType = "FileMesh"
	        shellmesh.Parent = Shell
	        game:GetService("Debris"):addItem(Shell,Module.DisappearTime)
		end	
		spawn(spawner)
		game.Debris:AddItem(Chamber,10)									
	end
end

function RecoilCamera()
	if Module.CameraRecoilingEnabled then
	    local CurrentRecoil = Module.Recoil*(AimDown and 1-Module.RecoilRedution or 1)
        local RecoilX = math.rad(CurrentRecoil * RAND(Module.AngleX_Min, Module.AngleX_Max, Module.Accuracy))
	    local RecoilY = math.rad(CurrentRecoil * RAND(Module.AngleY_Min, Module.AngleY_Max, Module.Accuracy))
	    local RecoilZ = math.rad(CurrentRecoil * RAND(Module.AngleZ_Min, Module.AngleZ_Max, Module.Accuracy))
	    CameraModule:accelerate(RecoilX,RecoilY,RecoilZ)	    
		delay(0.03, function()
		    CameraModule:accelerateXY(-RecoilX,-RecoilY)
	    end)
	end
end

function Fire(ShootingHandle, InputPos)
	if FireAnim then FireAnim:Play(nil,nil,Module.FireAnimationSpeed) end

	
    local FireDirection = (InputPos - ShootingHandle:FindFirstChild("GunFirePoint").WorldPosition).unit
	Player.PlayerScripts.BulletVisualizerClientScript.Visualize:Fire(Tool,ShootingHandle,FireDirection,
		                                                            ShootingHandle:FindFirstChild("GunFirePoint"),
															        {Module.HitEffectEnabled,Module.HitSoundIDs,Module.HitSoundPitchMin,Module.HitSoundPitchMax,Module.HitSoundVolume,script:WaitForChild("HitEffect"),Module.CustomHitEffect},
															        {Module.BloodEnabled,Module.HitCharSndIDs,Module.HitCharSndPitchMin,Module.HitCharSndPitchMax,Module.HitCharSndVolume,script:WaitForChild("BloodEffect")},
															        {Module.BulletHoleEnabled,Module.BulletHoleSize,Module.BulletHoleTexture,Module.PartColor,Module.BulletHoleVisibleTime,Module.BulletHoleFadeTime},
															        {Module.ExplosiveEnabled,Module.ExplosionRadius,Module.ExplosionSoundEnabled,Module.ExplosionSoundIDs,Module.ExplosionSoundPitchMin,Module.ExplosionSoundPitchMax,Module.ExplosionSoundVolume,Module.CustomExplosion,script:WaitForChild("ExplosionEffect")},
													                {Module.BulletTracerEnabled,Module.BulletTracerOffset0,Module.BulletTracerOffset1,script:WaitForChild("TracerEffect"),Module.BulletParticleEnaled,script:WaitForChild("ParticleEffect"),Module.Range,Module.BulletSpeed,Module.DropGravity,Module.WindOffset,Module.BulletSize,Module.BulletColor,Module.BulletTransparency,Module.BulletMaterial,Module.BulletShape,Module.BulletMeshEnabled,Module.BulletMeshID,Module.BulletTextureID,Module.BulletMeshScale},
													                {Module.BaseDamage,Module.HeadshotDamageMultiplier,Module.HeadshotEnabled},
	                                                                {Module.BulletLightEnabled,Module.BulletLightBrightness,Module.BulletLightColor,Module.BulletLightRange,Module.BulletLightShadows},
	                                                                {Module.Knockback, Module.Lifesteal, Module.FlamingBullet, Module.FreezingBullet, GunScript_Server:FindFirstChild("IgniteScript"), GunScript_Server:FindFirstChild("IcifyScript"), Module.IgniteChance, Module.IcifyChance},
	                                                                {Module.CriticalDamageEnabled,Module.CriticalBaseChance,Module.CriticalDamageMultiplier},
	                                                                {Module.GoreEffectEnabled,Module.GoreSoundIDs,Module.GoreSoundPitchMin,Module.GoreSoundPitchMax,Module.GoreSoundVolume,script:WaitForChild("GoreEffect")})
	VisualizeBullet:FireServer(Tool,ShootingHandle,FireDirection,
		                      ShootingHandle:FindFirstChild("GunFirePoint"),
							  {Module.HitEffectEnabled,Module.HitSoundIDs,Module.HitSoundPitchMin,Module.HitSoundPitchMax,Module.HitSoundVolume,script:WaitForChild("HitEffect"),Module.CustomHitEffect},
							  {Module.BloodEnabled,Module.HitCharSndIDs,Module.HitCharSndPitchMin,Module.HitCharSndPitchMax,Module.HitCharSndVolume,script:WaitForChild("BloodEffect")},
							  {Module.BulletHoleEnabled,Module.BulletHoleSize,Module.BulletHoleTexture,Module.PartColor,Module.BulletHoleVisibleTime,Module.BulletHoleFadeTime},
							  {Module.ExplosiveEnabled,Module.ExplosionRadius,Module.ExplosionSoundEnabled,Module.ExplosionSoundIDs,Module.ExplosionSoundPitchMin,Module.ExplosionSoundPitchMax,Module.ExplosionSoundVolume,Module.CustomExplosion,script:WaitForChild("ExplosionEffect")},
							  {Module.BulletTracerEnabled,Module.BulletTracerOffset0,Module.BulletTracerOffset1,script:WaitForChild("TracerEffect"),Module.BulletParticleEnaled,script:WaitForChild("ParticleEffect"),Module.Range,Module.BulletSpeed,Module.DropGravity,Module.WindOffset,Module.BulletSize,Module.BulletColor,Module.BulletTransparency,Module.BulletMaterial,Module.BulletShape,Module.BulletMeshEnabled,Module.BulletMeshID,Module.BulletTextureID,Module.BulletMeshScale},
	                          {Module.WhizSoundEnabled,Module.WhizSoundID,Module.WhizSoundVolume,Module.WhizSoundPitchMin,Module.WhizSoundPitchMax,Module.WhizDistance},
	                          {Module.BulletLightEnabled,Module.BulletLightBrightness,Module.BulletLightColor,Module.BulletLightRange,Module.BulletLightShadows})												
end

function Reload()
	if Enabled and not Reloading and (Ammo > 0 or not Module.LimitedAmmoEnabled) and Mag < Module.AmmoPerMag then
		Reloading = true
		if AimDown then
            TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			CrosshairModule:setcrossscale(1)
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
			if GUI then GUI:Destroy() end]]
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
		UpdateGUI()
		if Module.ShotgunReload then
			for i = 1,(Module.AmmoPerMag - Mag) do
				if ShotgunClipinAnim then ShotgunClipinAnim:Play(nil,nil,Module.ShotgunClipinAnimationSpeed) end
				Handle.ShotgunClipin:Play()
				wait(Module.ShellClipinSpeed)
			end
		end
		if ReloadAnim then ReloadAnim:Play(nil,nil,Module.ReloadAnimationSpeed) end
		Handle.ReloadSound:Play()
wait(0.4)
		Tool.Mag.Transparency = 1
Tool.Mag1.Transparency = 0
Tool.Mag6.Transparency = 1
wait(0.2)
        Tool.Mag1.Transparency = 1
        Tool.Mag2.Transparency = 0
Tool.Mag6.Transparency = 1
wait(0.2)
Tool.Mag2.Transparency = 1
Tool.Mag3.Transparency = 0
Tool.Mag6.Transparency = 1
wait(0.2)
Tool.Mag3.Transparency = 1
Tool.Mag4.Transparency = 0
wait(0.2)
Tool.Mag4.Transparency = 1
Tool.Mag5.Transparency = 0
wait(0.2)
Tool.Mag5.Transparency = 1
Tool.Mag6.Transparency = 0
wait(0.2)
Tool.Mag6.Transparency = 1
Tool.Mag4.Transparency = 1
Tool.Mag5.Transparency = 0
wait(0.2)
Tool.Mag4.Transparency = 0
Tool.Mag5.Transparency = 1
wait(0.2)
Tool.Mag3.Transparency = 0
Tool.Mag4.Transparency = 1
wait(0.2)
Tool.Mag2.Transparency = 0
Tool.Mag3.Transparency = 1
wait(0.2)
        Tool.Mag1.Transparency = 1
        Tool.Mag2.Transparency = 0
wait(0.2)
Tool.Mag2.Transparency = 1



		wait(Module.ReloadTime)
		if Module.LimitedAmmoEnabled then
		local ammoToUse = math.min(Module.AmmoPerMag - Mag, Ammo)
		Mag = Mag + ammoToUse
		Ammo = Ammo - ammoToUse
		else
	    Mag = Module.AmmoPerMag
		end
		ChangeMagAndAmmo:FireServer(Mag,Ammo)
		Reloading = false
		
		Tool.Mag.Transparency = 0
		UpdateGUI()
	end
end

function UpdateGUI()
	GUI.Frame.Mag.Fill:TweenSizeAndPosition(UDim2.new(Mag/Module.AmmoPerMag,0,1,0), UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
	GUI.Frame.Ammo.Fill:TweenSizeAndPosition(UDim2.new(Ammo/Module.MaxAmmo,0,1,0), UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
	GUI.Frame.Mag.Current.Text = Mag
	GUI.Frame.Mag.Max.Text = Module.AmmoPerMag
	GUI.Frame.Ammo.Current.Text = Ammo
	GUI.Frame.Ammo.Max.Text = Module.MaxAmmo

	GUI.Frame.Mag.Current.Visible = not Reloading
	GUI.Frame.Mag.Max.Visible = not Reloading
	GUI.Frame.Mag.Frame.Visible = not Reloading
	GUI.Frame.Mag.Reloading.Visible = Reloading

	GUI.Frame.Ammo.Current.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.Max.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.Frame.Visible = not (Ammo <= 0)
	GUI.Frame.Ammo.NoMoreAmmo.Visible = (Ammo <= 0)
	
	GUI.Frame.Ammo.Visible = Module.LimitedAmmoEnabled
	GUI.Frame.Size = Module.LimitedAmmoEnabled and UDim2.new(0,250,0,100) or UDim2.new(0,250,0,55)
	GUI.Frame.Position = Module.LimitedAmmoEnabled and UDim2.new(1,-260,1,-140)or UDim2.new(1,-260,1,-95)
	GUI.MobileButtons.Visible = UserInputService.TouchEnabled --For mobile version
	GUI.MobileButtons.AimButton.Visible = Module.SniperEnabled or Module.IronsightEnabled
	GUI.MobileButtons.HoldDownButton.Visible = Module.HoldDownEnabled
end

-- Mobile

GUI.MobileButtons.AimButton.MouseButton1Click:connect(function()
	if not Reloading and not HoldDown and AimDown == false and Equipped == true and Module.IronsightEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 1 then
        TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewIS}):Play()
        CrosshairModule:setcrossscale(Module.CrossScaleIS)
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveIS
		AimDown = true
	elseif not Reloading and not HoldDown and AimDown == false and Equipped == true and Module.SniperEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 1 then
		TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewS}):Play()
		CrosshairModule:setcrossscale(Module.CrossScaleS)
	    local zoomsound = GUI.Scope.ZoomSound:Clone()
	    zoomsound.Parent = Player.PlayerGui
        zoomsound:Play()
		Scoping = true
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveS
		AimDown = true
		game:GetService("Debris"):addItem(zoomsound,5)
	else
        TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
        CrosshairModule:setcrossscale(1)
		Scoping = false
		game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = InitialSensitivity
		AimDown = false
	end
end)

-- hold wait

GUI.MobileButtons.HoldDownButton.MouseButton1Click:connect(function()
	if not Reloading and not HoldDown and Module.HoldDownEnabled then
		HoldDown = true
		IdleAnim:Stop()
        if HoldDownAnim then HoldDownAnim:Play(nil,nil,Module.HoldDownAnimationSpeed) end
        if AimDown then
        TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
        CrosshairModule:setcrossscale(1)
	 	Scoping = false
        game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
        UserInputService.MouseDeltaSensitivity = InitialSensitivity
        AimDown = false
	    end
	else
		HoldDown = false
		IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed)
        if HoldDownAnim then HoldDownAnim:Stop() end
	end
end)



GUI.MobileButtons.ReloadButton.MouseButton1Click:connect(function()
    Reload()
end)



GUI.MobileButtons.FireButton.MouseButton1Down:connect(function()
	Down = true
	local IsChargedShot = false
	if Equipped and Enabled and Down and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 then
		Enabled = false
		if Module.ChargedShotEnabled then
			if HandleToFire:FindFirstChild("ChargeSound") then HandleToFire.ChargeSound:Play() end
			wait(Module.ChargingTime)
			IsChargedShot = true
		end
		if Module.MinigunEnabled then
			if HandleToFire:FindFirstChild("WindUp") then HandleToFire.WindUp:Play() end
			wait(Module.DelayBeforeFiring)
		end
		while Equipped and not Reloading and not HoldDown and (Down or IsChargedShot) and Mag > 0 and Humanoid.Health > 0 do
			IsChargedShot = false
			
			Player.PlayerScripts.BulletVisualizerServerScript.VisualizeM:Fire(HandleToFire,
				                                                             Module.MuzzleFlashEnabled,
			                                                                 {Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
			                                                                 script:WaitForChild("MuzzleEffect"))
			VisualizeMuzzle:FireServer(HandleToFire,
				                      Module.MuzzleFlashEnabled,
						              {Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
						              script:WaitForChild("MuzzleEffect"))	
			
			for i = 1,(Module.BurstFireEnabled and Module.BulletPerBurst or 1) do
				--VVV Edit here VVV--
				self.knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
				--^^^ Edit here ^^^--
				spawn(RecoilCamera)
				EjectShell(HandleToFire)
				CrosshairModule.crossspring:accelerate(Module.CrossExpansion)			
	            Player.PlayerScripts.BulletVisualizerServerScript.Play:Fire{
		            SoundId = HandleToFire.FireSound.SoundId,
		            Position = HandleToFire,
		            Effects = Module.EchoEffect,
		            Volume = HandleToFire.FireSound.Volume,
		            EmitterSize = HandleToFire.FireSound.EmitterSize,
		            Pitch = HandleToFire.FireSound.PlaybackSpeed,
		            Replicate = Module.Replicate
	            }		
				for x = 1,(Module.ShotgunEnabled and Module.BulletPerShot or 1) do
					local Position = Get3DPosition(GUI.Crosshair.AbsolutePosition)
					Fire(HandleToFire, Position)
				end
				Mag = Mag - 1
				ChangeMagAndAmmo:FireServer(Mag,Ammo)
				UpdateGUI()
				if Module.BurstFireEnabled then wait(Module.BurstRate) end
				if Mag <= 0 then break end
			end
			HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle
			wait(Module.FireRate)
			if not Module.Auto then break end
		end
		if HandleToFire.FireSound.Playing and HandleToFire.FireSound.Looped then HandleToFire.FireSound:Stop() end
		if Module.MinigunEnabled then
			if HandleToFire:FindFirstChild("WindDown") then HandleToFire.WindDown:Play() end
			wait(Module.DelayAfterFiring)
		end
		Enabled = true
		if Mag <= 0 then Reload() end
	end
end)



GUI.MobileButtons.FireButton.MouseButton1Up:connect(function()
	Down = false
end)



Mouse.Button1Down:connect(function()
	if not UserInputService.TouchEnabled then
	Down = true
	local IsChargedShot = false
	if Equipped and Enabled and Down and not Reloading and not HoldDown and Mag > 0 and Humanoid.Health > 0 then
		Enabled = false
		if Module.ChargedShotEnabled then
			if HandleToFire:FindFirstChild("ChargeSound") then HandleToFire.ChargeSound:Play() end
			wait(Module.ChargingTime)
			IsChargedShot = true
		end
		if Module.MinigunEnabled then
			if HandleToFire:FindFirstChild("WindUp") then HandleToFire.WindUp:Play() end
			wait(Module.DelayBeforeFiring)
		end
		while Equipped and not Reloading and not HoldDown and (Down or IsChargedShot) and Mag > 0 and Humanoid.Health > 0 do
			IsChargedShot = false
			
			Player.PlayerScripts.BulletVisualizerServerScript.VisualizeM:Fire(HandleToFire,
				                                                             Module.MuzzleFlashEnabled,
			                                                                 {Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
			                                                                 script:WaitForChild("MuzzleEffect"))
			VisualizeMuzzle:FireServer(HandleToFire,
				                      Module.MuzzleFlashEnabled,
						              {Module.MuzzleLightEnabled,Module.LightBrightness,Module.LightColor,Module.LightRange,Module.LightShadows,Module.VisibleTime},
						              script:WaitForChild("MuzzleEffect"))	
			
			for i = 1,(Module.BurstFireEnabled and Module.BulletPerBurst or 1) do
			
				self.knockback.t = 1 * Vector3.new(-1, -20 * .005, 0)
				
				spawn(RecoilCamera)
				EjectShell(HandleToFire)
				CrosshairModule.crossspring:accelerate(Module.CrossExpansion)
	            Player.PlayerScripts.BulletVisualizerServerScript.Play:Fire{
		            SoundId = HandleToFire.FireSound.SoundId,
		            Position = HandleToFire,
		            Effects = Module.EchoEffect,
		            Volume = HandleToFire.FireSound.Volume,
		            EmitterSize = HandleToFire.FireSound.EmitterSize,
		            Pitch = HandleToFire.FireSound.PlaybackSpeed,
		            Replicate = Module.Replicate
	            }		
				for x = 1,(Module.ShotgunEnabled and Module.BulletPerShot or 1) do
					local Position = Get3DPosition(Mouse)
					Fire(HandleToFire, Position)
				end
				Mag = Mag - 1
				ChangeMagAndAmmo:FireServer(Mag,Ammo)
				UpdateGUI()
				if Module.BurstFireEnabled then wait(Module.BurstRate) end
				if Mag <= 0 then break end
			end
			HandleToFire = (HandleToFire == Handle and Module.DualEnabled) and Handle2 or Handle
			wait(Module.FireRate)
			if not Module.Auto then break end
		end
		if HandleToFire.FireSound.Playing and HandleToFire.FireSound.Looped then HandleToFire.FireSound:Stop() end
		if Module.MinigunEnabled then
			if HandleToFire:FindFirstChild("WindDown") then HandleToFire.WindDown:Play() end
			wait(Module.DelayAfterFiring)
		end
		Enabled = true
		if Mag <= 0 then Reload() end
	end
	end
end)
Mouse.Button1Up:connect(function()
	if not UserInputService.TouchEnabled then
	    Down = false
	end
end)

ChangeMagAndAmmo.OnClientEvent:connect(function(ChangedMag,ChangedAmmo)
	Mag = ChangedMag
	Ammo = ChangedAmmo
	UpdateGUI()
end)
Tool.Equipped:connect(function(TempMouse)
	Equipped = true
	if Module.AmmoPerMag ~= math.huge then GUI.Frame.Visible = true end
	GUI.Parent = Player.PlayerGui
	UpdateGUI()
	Handle.EquippedSound:Play()
	if Module.WalkSpeedRedutionEnabled then
	Humanoid.WalkSpeed = Humanoid.WalkSpeed - Module.WalkSpeedRedution
	else
	Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	CrosshairModule:setcrosssettings(Module.CrossSize, Module.CrossSpeed, Module.CrossDamper)
	UserInputService.MouseIconEnabled = false
	if EquippedAnim then EquippedAnim:Play(nil,nil,Module.EquippedAnimationSpeed) end
	if IdleAnim then IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed) end
	TempMouse.KeyDown:connect(function(Key)
		if string.lower(Key) == "r" then
			Reload()
		elseif string.lower(Key) == "e" then
			if not Reloading and not HoldDown and Module.HoldDownEnabled then
				HoldDown = true
				IdleAnim:Stop()
                if HoldDownAnim then HoldDownAnim:Play(nil,nil,Module.HoldDownAnimationSpeed) end
    		    if AimDown then 
                    TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			        CrosshairModule:setcrossscale(1)
			
		        	Scoping = false
			        game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			        UserInputService.MouseDeltaSensitivity = InitialSensitivity
			        AimDown = false
	        	end
			else
				HoldDown = false
				IdleAnim:Play(nil,nil,Module.IdleAnimationSpeed)
                if HoldDownAnim then HoldDownAnim:Stop() end
			end
		end
	end)
	Mouse.Button2Down:connect(function()
		if not Reloading and not HoldDown and AimDown == false and Equipped == true and Module.IronsightEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
			    TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewIS}):Play()
                CrosshairModule:setcrossscale(Module.CrossScaleIS)
			
			
				game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveIS
				AimDown = true
		elseif not Reloading and not HoldDown and AimDown == false and Equipped == true and Module.SniperEnabled and (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude <= 1 then
			    TweeningService:Create(Camera, TweenInfo.new(Module.TweenLength, Module.EasingStyle, Module.EasingDirection), {FieldOfView = Module.FieldOfViewS}):Play()
				CrosshairModule:setcrossscale(Module.CrossScaleS)
		
			    local zoomsound = GUI.Scope.ZoomSound:Clone()
	            zoomsound.Parent = Player.PlayerGui
	            zoomsound:Play()
				Scoping = true
				game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				UserInputService.MouseDeltaSensitivity = InitialSensitivity * Module.MouseSensitiveS
				AimDown = true
				game:GetService("Debris"):addItem(zoomsound,zoomsound.TimeLength)
			end
	end)
	Mouse.Button2Up:connect(function()
		if AimDown then
            TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			CrosshairModule:setcrossscale(1)
		
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
	end)
	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = false
		local LeftArm = Tool.Parent:FindFirstChild("Left Arm") or Tool.Parent:FindFirstChild("LeftHand")
		local RightArm = Tool.Parent:FindFirstChild("Right Arm") or Tool.Parent:FindFirstChild("RightHand")
		if RightArm then
			local Grip = RightArm:WaitForChild("RightGrip",0.01)
			if Grip then
				Grip2 = Grip:Clone()
				Grip2.Name = "LeftGrip"
				Grip2.Part0 = LeftArm
				Grip2.Part1 = Handle2
				--Grip2.C1 = Grip2.C1:inverse()
				Grip2.Parent = LeftArm
			end
		end
	end
end)
Tool.Unequipped:connect(function()
	HoldDown = false
	Equipped = false
	GUI.Parent = script
	GUI.Frame.Visible = false
	if Module.WalkSpeedRedutionEnabled then
	Humanoid.WalkSpeed = Humanoid.WalkSpeed + Module.WalkSpeedRedution
	else
	Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	UserInputService.MouseIconEnabled = true
	if IdleAnim then IdleAnim:Stop() end
	if HoldDownAnim then HoldDownAnim:Stop() end
		if AimDown then
            TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			CrosshairModule:setcrossscale(1)
			
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = true
		if Grip2 then Grip2:Destroy() end
	end
end)
Humanoid.Died:connect(function()
	HoldDown = false
	Equipped = false
	GUI.Parent = script
	GUI.Frame.Visible = false
	if Module.WalkSpeedRedutionEnabled then
	Humanoid.WalkSpeed = Humanoid.WalkSpeed + Module.WalkSpeedRedution
	else
	Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	UserInputService.MouseIconEnabled = true
	if IdleAnim then IdleAnim:Stop() end
	if HoldDownAnim then HoldDownAnim:Stop() end
		if AimDown then
			TweeningService:Create(Camera, TweenInfo.new(Module.TweenLengthNAD, Module.EasingStyleNAD, Module.EasingDirectionNAD), {FieldOfView = 70}):Play()
			CrosshairModule:setcrossscale(1)
			--[[local GUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ZoomGui")
			if GUI then GUI:Destroy() end]]
			Scoping = false
			game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = InitialSensitivity
			AimDown = false
		end
	if Module.DualEnabled and not workspace.FilteringEnabled then
		Handle2.CanCollide = true
		if Grip2 then Grip2:Destroy() end
	end
end)



game:GetService("RunService"):BindToRenderStep("Scope", Enum.RenderPriority.First.Value, function(tick)		
	self.knockback.t = self.knockback.t:lerp(Vector3.new(), .2)
end)

game:GetService("RunService"):BindToRenderStep("Mouse", Enum.RenderPriority.Input.Value, function()
	local delta = UserInputService:GetMouseDelta() / Module.ScopeSensitive
	
	if Scoping and UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
	    GUI.Scope.Position = UDim2.new(0, self.scope.p.x + (self.knockback.p.y * 1000), 0, self.scope.p.y + (self.knockback.p.x * 200))
	    local offset = GUI.Scope.AbsoluteSize.x * 0.5
	    self.scope.t = Vector3.new(Mouse.x - offset - delta.x, Mouse.y - offset - delta.y, 0)
	    oldPosition = Vector2.new(Mouse.x, Mouse.y)
	elseif Scoping and UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then --For mobile version, but in first-person view
	    GUI.Scope.Position = UDim2.new(0, self.scope.p.x + (self.knockback.p.y * 1000), 0, self.scope.p.y + (self.knockback.p.x * 200))
	    local offset = GUI.Scope.AbsoluteSize.x * 0.5
	    self.scope.t = Vector3.new(GUI.Crosshair.AbsolutePosition.X - offset - delta.x, GUI.Crosshair.AbsolutePosition.Y - offset - delta.y, 0)
	    oldPosition = Vector2.new(GUI.Crosshair.AbsolutePosition.X, GUI.Crosshair.AbsolutePosition.Y)
	end
	
	GUI.Scope.Visible = Scoping
	if not Scoping then
	    GUI.Crosshair.Main.Visible = true
	else
		GUI.Crosshair.Main.Visible = false
	end
	
    if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
	    GUI.Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)    
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude > 2 then --For mobile version, but in third-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, 0, 0.4, -50)
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 2 then --For mobile version, but in first-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, -1, 0.5, -19)
    end
end)