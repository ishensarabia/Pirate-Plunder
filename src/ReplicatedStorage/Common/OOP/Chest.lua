local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Services
local CollectionService = game:GetService("CollectionService")
--Collections
local PiratesChests = {}
local SailorsChests = {}


local Chest = Object.new("Chest")
--local Chest = Object.newExtends("Chest",?)


function Chest.new(chest,chestName,chestAttachment,originCFrame,team)
	local obj = Chest:make()
	--local obj = Chest:super()
	obj.Model = chest
	obj.OriginCFrame = originCFrame
	obj.Index = chestName
	obj.Team = team
	--Set up proximity prompt 
	obj.ProximityPrompt = Instance.new("ProximityPrompt", chestAttachment)
	obj.ProximityPrompt.Enabled = true
	obj.ProximityPrompt.MaxActivationDistance = 4
	obj.ProximityPrompt.HoldDuration = 1
	obj.ProximityPrompt.ObjectText = "To"
	obj.ProximityPrompt.ActionText = "pick up chest"
	obj.ProximityPrompt:SetAttribute("Object","Chest")

	return obj
end


function Chest:GetChest(chestIndex)
	for index, ChestClass in pairs(SailorsChests) do
		if ChestClass:GetIndex() == chestIndex then
			return ChestClass
		end	
	end	

	for index, ChestClass in pairs(PiratesChests) do
		if ChestClass:GetIndex() == chestIndex then
			return ChestClass
		end	
	end	

end	

function Chest:GetIndex()
	return self.Index
end	

function Chest:GetTeam()
	return self.Team
end

function Chest:PickUpChest(player)
	if player.Character and not player:FindFirstChild("HasChest") and game.ReplicatedStorage.Common.GameValues.GameInProgress.Value then
		local hasChest = Instance.new("StringValue",player)
		hasChest.Name = "HasChest"
		hasChest.Value = self.Index


		--Weld the chest to the player hand and identify the chest
		local chest = game.ReplicatedStorage.Common.Assets.Chest:Clone()
		chest.Parent = player.Character
		chest.Name = self.Index
		--Clear the backpack
		player.Backpack:ClearAllChildren()
		player.Character.Humanoid:EquipTool(chest)
		
		

		--Play animation
		player.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.Common.Assets.CarryChest):Play()

		--Disable chest
		for index, child in pairs (self.Model:GetDescendants()) do
			if child:IsA("Decal") or child:IsA("BasePart") then
				child.Transparency = 1
			end
	
			if child:IsA("ProximityPrompt") then
				child.Enabled = false
			end	

			if child:IsA("BillboardGui") then
				child.Enabled = false
			end	
		end	
	end

	
end	

function Chest:DropChest(humanoidRootPart)
	self.Model:MoveTo(humanoidRootPart.Position)
	--Make the chest appearence 
	for i , child in pairs(self.Model:GetDescendants()) do
		if child:IsA("Decal")  then
			child.Transparency = 0
		end

		if child:IsA("BasePart") or child:IsA("MeshPart") then
			child.Transparency = 0
			child.Anchored = false
		end

		if child:IsA("ProximityPrompt") then
			child.Enabled = true
		end	
		
		if child:IsA("BillboardGui") then
			child.Enabled = true
		end	
	end	

	spawn(function()
		wait(30)
		--Move it to the origin point
		self.Model:SetPrimaryPartCFrame(self.OriginCFrame)
	end)
end	

function Chest:RespawnChest()
	--Make the chest appearence 
	for i , child in pairs(self.Model:GetDescendants()) do
		if child:IsA("Decal")  then
			child.Transparency = 0
		end

		if child:IsA("BasePart") or child:IsA("MeshPart") then
			child.Transparency = 0
			child.Anchored = false
		end

		if child:IsA("ProximityPrompt") then
			child.Enabled = true
		end	
		
		if child:IsA("BillboardGui") then
			child.Enabled = true
		end	
	end	
	--Move it to the origin point
	self.Model:SetPrimaryPartCFrame(self.OriginCFrame)
end
-----------------------------Events and initialization of the object --------------------------------
game:GetService('Players').PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			if player:FindFirstChild("HasChest") then
				local chestIndex = player:FindFirstChild("HasChest").Value
				local ChestToDrop = Chest:GetChest(chestIndex)
				ChestToDrop:DropChest(character.HumanoidRootPart)
				player:FindFirstChild("HasChest"):Destroy()
			end	
		end)
	end)
end)

for index, chest in pairs(CollectionService:GetTagged("PirateChest")) do
	local NewChest = Chest.new(chest,chest.Name,chest["MainPart"].Attachment,chest.PrimaryPart.CFrame,"Pirates")	
	table.insert(PiratesChests, NewChest)
end

for index, chest in pairs(CollectionService:GetTagged("SailorChest")) do
	local NewChest= Chest.new(chest,chest.Name,chest["MainPart"].Attachment,chest.PrimaryPart.CFrame,"Sailors")
	table.insert(SailorsChests, NewChest)
end

return Chest