-- totally not from nocollider
local cf = CFrame.new
local v3 = Vector3.new
local isa = game.IsA
local ray = Ray.new 
local ffp = workspace.FindPartOnRayWithIgnoreList
local time = tick
local RENDER_DISTANCE = 400
local gibs = script:WaitForChild("gibs"):clone()

local replicated_storage = game ("GetService", "ReplicatedStorage")
local runtime = game ("GetService", "RunService")
local debris = game ("GetService", "Debris")

local camera = workspace.CurrentCamera
local remote_event = replicated_storage:WaitForChild "VisualizeGore"

local joints = {}
local gore = {
	["Head"] = {gibs["neck"], gibs["head"]},
	["Right Arm"] = {gibs["right.shoulder"], gibs["right.arm"]},
	["Left Arm"] = {gibs["left.shoulder"], gibs["left.arm"]},
	["Right Leg"] = {gibs["right.hip"], gibs["right.leg"]},
	["Left Leg"] = {gibs["left.hip"], gibs["left.leg"]},
}
local function weld(x,y)
	local z = gibs.rig[x.Name]
	local CJ = CFrame.new(z.Position)
	local C0 = z.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
	
	return W
end
local function gib_joint(joint, ragdoll, gore_data)
	if gore_data[1] then
	    if ragdoll:FindFirstChild "Torso" and joint.Transparency ~= 1 and not ragdoll:FindFirstChild "gibbed" and (joint.Position - camera.CFrame.p).magnitude < RENDER_DISTANCE then	
		    joint.Transparency = 1
		    local tag = Instance.new("StringValue", ragdoll)
		    tag.Name = "gibbed"
		
		    local decal = joint:FindFirstChildOfClass "Decal" 
		    if decal then
			    decal:Destroy()
		    end
		    if joint.Name:match("Left") or joint.Name:match("Right") then
			    local debry = gibs.debry:clone()
			    debry.CFrame = joint.CFrame * CFrame.new(0, -.5, 0)
			    debry.RotVelocity = Vector3.new(50, 0, 0)
			    debry.Parent = ragdoll
		    end
		    local splat, limb = unpack(gore[joint.Name])
		
		    limb = limb:clone()
		    limb.Anchored = true
		    limb.CanCollide = false
		    limb.Parent = ragdoll
		    local offset = gibs.rig[joint.Name].CFrame:toObjectSpace(limb.CFrame)
		    joints[limb] = function()return joint.CFrame * offset end

		    splat = splat:clone()
		    splat.Anchored = true
		    splat.CanCollide = false
		    splat.Parent = ragdoll
		    local offset = gibs.rig.Torso.CFrame:toObjectSpace(splat.CFrame) 
		    joints[splat] = function()if ragdoll:FindFirstChild"Torso" then return ragdoll.Torso.CFrame * offset end end
		
		    local Attachment = Instance.new("Attachment")
		    Attachment.CFrame = joint.CFrame
	        Attachment.Parent = workspace.Terrain
		    local Sound = Instance.new("Sound",Attachment)
		    Sound.SoundId = "rbxassetid://"..gore_data[2][math.random(1,#gore_data[2])]
		    Sound.PlaybackSpeed = Random.new():NextNumber(gore_data[3], gore_data[4])
		    Sound.Volume = gore_data[5]
			
		    local function spawner()
	            local C = gore_data[6]:GetChildren()
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
		
		    spawn(spawner)
		    game.Debris:AddItem(Attachment,10)	
		
	    end
	end
end
local gib = script.gib
gib.Parent = game.ReplicatedStorage
gib.Event:connect(gib_joint)
remote_event.OnClientEvent:connect(function(...)
	local crap = {...}
	if crap[1] == "}13,{\n\n}" then
		gib_joint(crap[2], crap[3], crap[4])
	end
end)
game ("GetService", "RunService").RenderStepped:connect(function(tick)
	for part, cframe in next, joints do
		part.CFrame = cframe()
	end
end)
-- ok fine, nocollider made it