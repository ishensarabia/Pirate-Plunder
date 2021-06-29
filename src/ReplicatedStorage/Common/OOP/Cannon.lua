local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
--Collection
local Cannons = {}
-- Events
local events =game.ReplicatedStorage.Common.CannonSystem.Remotes

local Cannon = Object.new("Cannon")
--local Cannon = Object.newExtends("Cannon",?)

function Cannon.new(model,attachment)
	local obj = Cannon:make()
	--local obj = Cannon:super()
	obj.Model = model
	obj.Type = model:GetAttribute("Type")
	obj.IsOccupied = false
	obj.Occupant = nil
		--Set up proximity prompt 
	obj.ProximityPrompt = Instance.new("ProximityPrompt", attachment)
	obj.ProximityPrompt.Enabled = true
	obj.ProximityPrompt.MaxActivationDistance = 4
	obj.ProximityPrompt.HoldDuration = 1
	obj.ProximityPrompt.ObjectText = "To"
	obj.ProximityPrompt.ActionText = "use cannon"
	obj.ProximityPrompt:SetAttribute("Object","Cannon")
	obj.ProximityPrompt:SetAttribute("ID",obj:GetID())
	return obj
end

function Cannon:LeaveCannon()
	if RunService:IsServer() then
		self:SetOccupied(false)
	end

	if RunService:IsClient() then
		events.LeaveCannon:FireServer()
	end	
end

function Cannon:CheckIsOccupied()
	if self.IsOccupied then
		return true
	else
		return false	
	end
end

function Cannon:SetOccupied(value,player)
	self.IsOccupied = value	
	if not self.IsOccupied then
		self.ProximityPrompt.Enabled = false
		if self.Occupant then
			self.Occupant:SetAttribute("CannonID", nil)
			self.ProximityPrompt.Enabled = true	
		end	
	else
		if player then
			player:SetAttribute("CannonID", self:GetID())
			self.Occupant = player
			--Turns on client control
			game.ReplicatedStorage.Common.CannonSystem.Remotes.UseCannon:FireClient(player,self:GetModel())  
			self.ProximityPrompt.Enabled = false
		end
	end	


end

function Cannon:ShootCannon(mousePosition)
	if RunService:IsServer() then
		if self:GetType() == "Human" then
			self:ShootHuman(mousePosition)
		end	
		if self:GetType() == "Ball" then
			self:ShootCannonBall(mousePosition)
		end
	end

	if RunService:IsClient() then
		events.FireCannon:FireServer(mousePosition)
	end	
end

--Cannon math 
local function Explode(part)
	local explosion = Instance.new("Explosion", workspace)
	explosion.Position = part.Position
	explosion.BlastRadius = 5
	part:Destroy()
end

local function AngleOfReach(distance, altitude, velocity)
	local gravity = workspace.Gravity
	local theta = math.atan((velocity^2 + math.sqrt(velocity^4 -gravity*(gravity*distance^2 + 2*altitude*velocity^2)))/(gravity*distance))
	if theta ~= theta then
		theta = math.pi/4
	end
	return(theta)
end

function Cannon:ShootCannonBall(mousePosition)

    local cannonMainPart = self:GetModel().PrimaryPart
    local cannonMainPartPos = Vector3.new(cannonMainPart.Position.X, 0, cannonMainPart.Position.Z)
    local distance = (cannonMainPartPos - mousePosition).Magnitude
    local altitude = mousePosition.Y - cannonMainPart.Position.Y
    local angle = AngleOfReach(distance,altitude,200)
    
    local cannonBall = game.ReplicatedStorage.Common.Assets.CannonBall:Clone()

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://715549761"
    sound:Play()
    sound.Parent = cannonBall

    cannonBall.Parent = workspace
    cannonBall.CFrame = cannonMainPart.CFrame +Vector3.new(-15,0.2,0)
    cannonBall.Velocity = (CFrame.new(cannonBall.Position,  Vector3.new(mousePosition.X, cannonBall.Position.Y, mousePosition.Z)) * CFrame.Angles(angle, 0, 0)).lookVector * 220

	
    spawn(function()
        cannonBall.Touched:Connect(function(hit)
            if hit.Parent ~= cannonMainPart.Parent and hit.CanCollide then -- Make sure what we're hitting is collidable
                Explode(cannonBall)
            end
        end)
    end)
end

function Cannon:ShootHuman(mousePosition)
		local player = self.Occupant
		local playerHead = player.Character.Head:Clone()
		player.Character.Humanoid.WalkSpeed = 0

	--Math
		local cannonMainPart = self:GetModel().PrimaryPart
		local cannonMainPartPos = Vector3.new(cannonMainPart.Position.X, 0, cannonMainPart.Position.Z)
		local distance = (cannonMainPartPos - mousePosition).Magnitude
		local altitude = mousePosition.Y - cannonMainPart.Position.Y
		local angle = AngleOfReach(distance,altitude,200)

		playerHead.Parent = self.Model
		playerHead.Anchored = true
		playerHead.CFrame = self.Model.HeadPosition.CFrame
	-- Hide the character
		for _, child in ipairs(player.Character:GetDescendants()) do
			if child:IsA("BasePart") then
				child.Transparency = 1
				child.CanCollide = false
			end

			if child:IsA("Decal") then
				child.Transparency = 1
			end	
		end
		local igniteSound = Instance.new("Sound")
		igniteSound.SoundId = "rbxassetid://907668984"
		igniteSound:Play()
		igniteSound.Parent = playerHead
		igniteSound.Ended:Wait()

	--Reappear the character
		for _, child in ipairs(player.Character:GetDescendants()) do
			if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
				child.Transparency = 0
				child.CanCollide = true
			end

			if child:IsA("Decal") then
				child.Transparency = 0
			end	
		end
		
		local fireSound = Instance.new("Sound")
		fireSound.SoundId = "rbxassetid://715549761"
		fireSound:Play()
		fireSound.Parent = playerHead

		player.Character:MoveTo(self.Model.HeadPosition.Position)
		player.Character.Humanoid.WalkSpeed = 16
		player.Character.HumanoidRootPart.Velocity =  (CFrame.new(player.Character.HumanoidRootPart.Position,  Vector3.new(mousePosition.X, player.Character.HumanoidRootPart.Position.Y, mousePosition.Z)) * CFrame.Angles(angle, 0, 0)).lookVector * 550
		self:SetOccupied(false)
		playerHead:Destroy()
		
end

function Cannon:GetType()
	return self.Type
end

function Cannon:GetModel()
	return self.Model
end

function Cannon:GetCannon(ID)
	for index, cannon in pairs(Cannons) do
		print("Looping cannons to search ID: " .. ID)
		if cannon:GetID() == ID then
			print("Found cannon")
			return cannon
		end
	end
end

function Cannon:InitializeObject()
	for index, cannon in pairs(CollectionService:GetTagged("Cannon")) do

		local NewCannon = Cannon.new(cannon,cannon.PrimaryPart.Attachment)
		table.insert(Cannons, NewCannon)
		
	end
end	


return Cannon