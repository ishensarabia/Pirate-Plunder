


local Module = {

		Auto = false;
	    FireRate = 0.2; 
		ReloadTime = 1; 
		AmmoPerMag = math.huge;
		BaseDamage = 20; 
		SpreadX = 5; 
		SpreadY = 5; 
		Range = 7; 
		HeadshotEnabled = true; 
		HeadshotDamageMultiplier = 2;
		EquippedAnimationID = nil;
		EquippedAnimationSpeed = 1;
	IdleAnimationID = 6648809171; -- Change these to your animation Id
		IdleAnimationSpeed = 0.2;
	FireAnimationID = 6648821917; -- Change these to your animation Id
		FireAnimationSpeed = 1;
	ReloadAnimationID = 5712214088; -- Change these to your animation Id
		ReloadAnimationSpeed = 0.3;
		
		--Random damage

        CriticalDamageEnabled = false;
        CriticalBaseChance = 5; --In percent
        CriticalDamageMultiplier = 3;

-- SOund effects dont change 

        GoreEffectEnabled = true;
		GoreSoundIDs = {1930359546};
		GoreSoundPitchMin = 1;
	    GoreSoundPitchMax = 1.5; 
		GoreSoundVolume = 1;

-- SHooting sound
		
		EchoEffect = true; --Create echo effect from distance
		Replicate = true;

-- Speed reduction

        WalkSpeedRedutionEnabled = true;
        WalkSpeedRedution = 1;
		

-- Hold

        HoldDownEnabled = false;
        HoldDownAnimationID = nil;
        HoldDownAnimationSpeed = 0.5;
		
--Hole effects

        BulletHoleEnabled = false;
        BulletHoleSize = 0.5;
        BulletHoleTexture = {2078626};
        BulletHoleVisibleTime = 1000;
        BulletHoleFadeTime = 1; 
        PartColor = true; 

-- Speed reduction

        WalkSpeedRedutionEnabled = true;
        WalkSpeedRedution = 1;

-- Bullet

        BloodEnabled = false;
		HitCharSndIDs = {3802437008, 3802437361, 3802437696, 3802440043, 3802440388, 3802442962};
		HitCharSndPitchMin = 1; 
	    HitCharSndPitchMax = 1; 
		HitCharSndVolume = 1;
		
		--Hit sound

        HitEffectEnabled = true;
		HitSoundIDs = {186809061, 186809249, 186809250, 186809252};
		HitSoundPitchMin = 1;
	    HitSoundPitchMax = 1.5;
		HitSoundVolume = 1;
        CustomHitEffect = false; 
		

--	iron sight settings
        TweenLength = 0.3; --In second
        EasingStyle = Enum.EasingStyle.Quint; --Linear, Sine, Back, Quad, Quart, Quint, Bounce or Elastic?
        EasingDirection = Enum.EasingDirection.Out; --In, Out or InOut?

-- iron sight settings

        TweenLengthNAD = 0.8; 
        EasingStyleNAD = Enum.EasingStyle.Quint; 
        EasingDirectionNAD = Enum.EasingDirection.Out; 
		
--	WHiz


        WhizSoundEnabled = true;
        WhizSoundID = {269514869, 269514887, 269514807, 269514817};
        WhizSoundVolume = 0.5;
		WhizSoundPitchMin = 1; 
	    WhizSoundPitchMax = 1.5; 
	    WhizDistance = 25;
		
-- Cross hair

        CrossSize = 3.2;
        CrossExpansion = 10;
        CrossSpeed = 15;
        CrossDamper	= 1;

--Hit marker

        HitmarkerEnabled = true;
        HitmarkerSoundID = {3748776946, 3748777642, 3748780065};
        HitmarkerColor = Color3.fromRGB(255, 255, 255);
        HitmarkerFadeTime = 0.4;
        HitmarkerSoundPitch = 1;
        HitmarkerColorHS = Color3.fromRGB(255, 0, 0);
        HitmarkerFadeTimeHS = 0.4;
        HitmarkerSoundPitchHS = 1;

		
--	MUZZLE effects
        
        MuzzleFlashEnabled = true;
        MuzzleLightEnabled = true;
        LightBrightness = 4;
        LightColor = Color3.new(255/255, 283/255, 0/255);
        LightRange = 15;
        LightShadows = true;
        VisibleTime = 0.01; 
		
--shell

		BulletShellEnabled = false;
		BulletShellOffset = Vector3.new(0, 0, 0);
		ShellSize = Vector3.new(0, 0, 0); 
		AllowCollide = false; 
		ShellScale = Vector3.new(0.003,0.005,0.005); 
		ShellMeshID = 430333724;
		ShellTextureID = 430333742;
		DisappearTime = 1000; 
		
--Iron sight

		IronsightEnabled = false;
		FieldOfViewIS = 50;
		MouseSensitiveIS = 0.2;
		SpreadRedutionIS = 0.6; 
		CrossScaleIS = 0.6;
		
-- ammo

		LimitedAmmoEnabled = false;
		Ammo = 90; -- ammo given wehn gun picked up
		MaxAmmo = 90; -- max ammo change this to whatever u want
		
--shotgun

		ShotgunEnabled = false;
		BulletPerShot = 8;
		
		ShotgunReload = false; 
		ShotgunClipinAnimationID = nil;
		ShotgunClipinAnimationSpeed = 1;
		ShellClipinSpeed = 0.5; 

		
--Burst

		BurstFireEnabled = false;
		BulletPerBurst = 2;
		BurstRate = 1; 
		
		--Sniper

		SniperEnabled = false;
		FieldOfViewS = 12.5;
		MouseSensitiveS = 0.2; 
		SpreadRedutionS = 0.6; 
		CrossScaleS = 0;
		ScopeSensitive = 0.25;
		ScopeKnockbackSpeed = 7;
        ScopeKnockbackDamper = 0.65;
		ScopeSwaySpeed = 10;
        ScopeSwayDamper	= 0.4;


		
-- Recoil

		CameraRecoilingEnabled = true;
		Recoil = 50;
		RecoilRedution = 0;
		 RecoilSpeed = 12;
		 RecoilDamper = 0.65; 
		AngleX_Min = 2; 
		AngleX_Max = 2; 
		AngleY_Min = 0.02; 
		AngleY_Max = 0.02; 
		AngleZ_Min = -1;
		AngleZ_Max = 1; 
        Accuracy = 0.001; 
		 
	
--	Rockets

		ExplosiveEnabled = false;
		ExplosionSoundEnabled = true;
		ExplosionSoundIDs = {163064102};
		ExplosionSoundVolume = 1;
		ExplosionSoundPitchMin = 1; 
	    ExplosionSoundPitchMax = 1.5;
		ExplosionRadius = 8;
		CustomExplosion = false;
		
-- Bullet properties

		BulletTracerEnabled = false; 
		BulletParticleEnaled = false; 
		BulletTracerOffset0 = Vector3.new(0.2, 0, 0); 
		BulletTracerOffset1 = Vector3.new(-0.2, 0, 0);
		BulletSpeed = 100; 
		DropGravity = 400; 
		WindOffset = Vector3.new(0, 0, 0); 
		BulletSize = Vector3.new(0.4, 0.4, 0.4);
		BulletColor = Color3.fromRGB(245, 205, 48);
		BulletTransparency = 1;
		BulletMaterial = Enum.Material.Neon;
        BulletShape = Enum.PartType.Block; 

        BulletMeshEnabled = false; 
        BulletMeshID = 430333724;
        BulletTextureID = 437259505;
        BulletMeshScale = Vector3.new(0.002, 0.002, 0.002);

        BulletLightEnabled = false;
        BulletLightBrightness = 2;
        BulletLightColor = Color3.fromRGB(255, 165, 153);
        BulletLightRange = 10;
        BulletLightShadows = true;
		
-- rail
		
		ChargedShotEnabled = false;
		ChargingTime = 1;
		
-- Minigun

		MinigunEnabled = false;
		DelayBeforeFiring = 1;
		DelayAfterFiring = 1;
		
-- Bullet reactions

		Knockback = 0; 
		Lifesteal = 0; 
		FlamingBullet = false;
        IgniteChance = 100;

		FreezingBullet = false; 
        IcifyChance = 100;
       -- Dual welding
		DualEnabled = false;
		

}

return Module