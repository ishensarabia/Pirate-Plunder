-----------------Service-------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
-------------Shop Frame---------------------------------
local shop = script.Parent
--------------Modules------------------------------------
local displayModule  = require(game.Players.LocalPlayer.PlayerGui:WaitForChild("DisplayModule"))
--------------Buttons------------------------------------
local buttonSound = script.Parent.Parent.button
--------------Shops Frames-------------------------------
local skins = shop:WaitForChild("Skins")
local traps = shop:WaitForChild("Traps") 
local hexCrystals = shop:WaitForChild("HexCrystals")
--------------Shop Buttons---------------------------------
local skinsBtn = shop:WaitForChild("SkinsButton")
local trapsBtn = shop:WaitForChild("TrapsButton")
local hexCrystalsBtn = shop:WaitForChild("HexCrystalsButton")
--------------Item templates frames-------------------------
local itemsTemplates = script:WaitForChild("ItemsTemplates")
--------------Images for buttons----------------------------
local cart = "http://www.roblox.com/asset/?id=3130587434"
local bought = "rbxassetid://5320708552"
local equipped = "rbxassetid://5320734763"

--------------Table of developer products id----------
local crystalsID = {
	
	["100"] = "1027441882";
	["500"] = "1027512685";
	["750"] = "1027515228";
	["1000"] = "1027517422";
	["2500"] = "1027692467";
	["5000"] = "1027700631";
	
}


------------function to prompt purchase---------------
local localPlayer = game.Players.LocalPlayer

local function promptPurchase(player,productID)
	MarketplaceService:PromptProductPurchase(player, productID)
end



---------------Events--------------------------------
skinsBtn.MouseButton1Click:Connect(function()
	-- Hide traps menu
	trapsBtn.TextTransparency = 0.5
	hexCrystalsBtn.TextTransparency = 0.5

	traps.Visible = false
	hexCrystals.Visible = false
	buttonSound:Play()
	
	-- Show skins menu
	skinsBtn.TextTransparency = 0
	skins.Visible = true
end)

hexCrystalsBtn.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(game.Workspace.Camera, TweenInfo.new(3), {CFrame = game.Workspace:WaitForChild("IntroScene"):WaitForChild("HexCrystals").CFrame})
	tween:Play()
	trapsBtn.TextTransparency = 0.5
	skinsBtn.TextTransparency = 0.5
	
	traps.Visible = false
	
	hexCrystals.Visible = true
	skins.Visible = false
	buttonSound:Play()
	
	hexCrystalsBtn.TextTransparency = 0
	hexCrystals.Visible = true

end)

trapsBtn.MouseButton1Click:Connect(function()
	-- Hide skins menu
	skinsBtn.TextTransparency = 0.5
	hexCrystalsBtn.TextTransparency = 0.5

	skins.Visible = false
	hexCrystals.Visible = false
	buttonSound:Play()
	
	-- Show traps menu
	trapsBtn.TextTransparency = 0
	traps.Visible = true
end)

local skinsData = game.ReplicatedStorage.Skins:GetChildren() -- Return a table of all the skins
local trapsData = game.ReplicatedStorage.Traps:GetChildren() -- Return a table of all the traps in the game
local hexCrystalsData = game.ReplicatedStorage.HexCrystals:GetChildren() -- Return a table of all the purchasable currency in game

local spinObject = function(model,camera)
	
	local currentAngle = 0
	local modelCF, modelSize = model:GetBoundingBox()
	
	local rotInv = (modelCF - modelCF.p):inverse()
	modelCF = modelCF * rotInv
	modelSize = rotInv * modelSize
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))
	
	local diagonal = 0
	local maxExtent = math.max(modelSize.x, modelSize.y, modelSize.z)
	local tan = math.tan(math.rad(camera.FieldOfView/2))
	
	if (maxExtent == modelSize.x) then
		diagonal = math.sqrt(modelSize.y*modelSize.y + modelSize.z*modelSize.z)/2
	elseif (maxExtent == modelSize.y) then
		diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.z*modelSize.z)/2
	else
		diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.y*modelSize.y)/2
	end
	
	local minDist = (maxExtent/2)/tan + diagonal

	return game:GetService("RunService").RenderStepped:Connect(function(dt)
		currentAngle = currentAngle + 1*dt*60
		camera.CFrame = modelCF * CFrame.fromEulerAnglesYXZ(0, math.rad(currentAngle), 0) * CFrame.new(0, 0, minDist)
	end)
	
end

local spinObjectPart = function(model,camera)
	
	local currentAngle = 0
	local modelCF, modelSize = model.CFrame, model.Size
	
	local rotInv = (modelCF - modelCF.p):inverse()
	modelCF = modelCF * rotInv
	modelSize = rotInv * modelSize
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))
	
	local diagonal = 0
	local maxExtent = math.max(modelSize.x, modelSize.y, modelSize.z)
	local tan = math.tan(math.rad(camera.FieldOfView/2))
	
	if (maxExtent == modelSize.x) then
		diagonal = math.sqrt(modelSize.y*modelSize.y + modelSize.z*modelSize.z)/2
	elseif (maxExtent == modelSize.y) then
		diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.z*modelSize.z)/2
	else
		diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.y*modelSize.y)/2
	end
	
	local minDist = (maxExtent/2)/tan + diagonal

	return game:GetService("RunService").RenderStepped:Connect(function(dt)
		currentAngle = currentAngle + 1*dt*60
		camera.CFrame = modelCF * CFrame.fromEulerAnglesYXZ(0, math.rad(currentAngle), 0) * CFrame.new(0, 0, minDist)
	end)
	
end



function createFrame(name,cost,object,parent,itemType,itemRarity)
	local frame = itemsTemplates[itemRarity.Value.."Template"]:Clone()
	frame.Name = name
	frame.Title.Text = name
	frame.Cost.Text = displayModule.comma_value(cost)
	
	local VPFObj = object:Clone()
	VPFObj.Parent = frame.ViewportFrame
	
	local cam = Instance.new("Camera")
	cam.Parent = frame.ViewportFrame
	
	if itemType == "skin" then
		-- set camera cframe to the character's head
		cam.CFrame = CFrame.new(object.Head.Position + (object.Head.CFrame.lookVector*5) + Vector3.new(0,2,3), object.Head.Position)
		spinObject(VPFObj,cam)	

	elseif itemType == "trap" then
		-- set camera cframe to the object (part)
		cam.CFrame = CFrame.new(object.Position + (object.CFrame.lookVector*5) + Vector3.new(0,2,3), object.Position)
		spinObjectPart(VPFObj,cam)
	elseif itemType == "crystal" then
		cam.CFrame = CFrame.new(VPFObj.PrimaryPart.Position + (VPFObj.PrimaryPart.CFrame.lookVector*5) + Vector3.new(0,2,0), VPFObj.PrimaryPart.Position)
		spinObject(VPFObj,cam)	
	end
	
	frame.ViewportFrame.CurrentCamera = cam
	
	frame.Parent = parent
	
	return frame	
end

function addHexCrystals(data)
	for i, v in pairs(data) do
		local frame = createFrame(displayModule.comma_value(v.Name),v.Cost.Value,v,hexCrystals.Folder,"crystal",v.Rarity)
		

		frame.Button.MouseButton1Click:Connect(function() -- Button to buy touched
			
			promptPurchase(localPlayer,crystalsID[v.Name])
							
		end)
		
	end
end


function addSkins(data)
	for i, v in pairs(data) do
			
		local frame = createFrame(v.Name,v.Cost.Value,v,skins.Folder,"skin",v.SkinRarity)

	
		
		if game.Players.LocalPlayer.SkinInventory:FindFirstChild(v.Name) then
			frame.Cost.Text = "Owned"
			frame.Button.Image = bought
		end
		
		if game.Players.LocalPlayer.EquippedSkin.Value == v.Name then
			frame.Cost.Text = "Equipped"
			frame.Button.Image = equipped
		end
		
		frame.Button.MouseButton1Click:Connect(function()
			local result = game.ReplicatedStorage.BuyItem:InvokeServer(v.Name,"skin")
			
			if result == "bought" then
				-- Purchase was a success
				
				frame.Button.Image = bought
				frame.Cost.Text = "Owned"
				
		    elseif result == "equipped" then
				-- You equipped the item
				
				for _, object in pairs(skins.Folder:GetChildren()) do
					if object:IsA("Frame") and object:FindFirstChild("Cost") then
						if game.Players.LocalPlayer.SkinInventory:FindFirstChild(object.Name) then
							object.Cost.Text = "Owned"
							object.Button.Image = bought
						end						
					end
				end
				
				frame.Button.Image = equipped
				frame.Cost.Text = "Equipped"
								
			end						
															
		end)
		
	end
end

function addTraps(data)
	for i, v in pairs(data) do
		local frame = createFrame(v.Name,v.Cost.Value,v,traps.Folder,"trap",v.TrapRarity)
		
		if game.Players.LocalPlayer.TrapInventory:FindFirstChild(v.Name) then
			frame.Cost.Text = "Owned"
			frame.Button.Image = bought
		end
		
		if game.Players.LocalPlayer.EquippedTrap.Value == v.Name then
			frame.Cost.Text = "Equipped"
			frame.Button.Image = equipped
		end
		
		frame.Button.MouseButton1Click:Connect(function()
			local result = game.ReplicatedStorage.BuyItem:InvokeServer(v.Name,"trap")
			
			if result == "bought" then
				-- Purchase was a success
				
				frame.Button.Image = bought
				frame.Cost.Text = "Owned"
				
		    elseif result == "equipped" then
				-- You equipped the item
				for _, object in pairs(traps.Folder:GetChildren()) do
					if object:IsA("Frame") and object:FindFirstChild("Cost") then
						if game.Players.LocalPlayer.TrapInventory:FindFirstChild(object.Name) then
							object.Cost.Text = "Owned"
							object.Button.Image = bought
						end						
					end
				end
				
				frame.Button.Image = equipped
				frame.Cost.Text = "Equipped"
								
			end						
															
		end)
		
	end
end

game.ReplicatedStorage.SendData.OnClientEvent:Connect(function()
	addSkins(skinsData)
	addTraps(trapsData)	
	addHexCrystals(hexCrystalsData)
end)

game.ReplicatedStorage.NotEnoughHexCrystals.OnClientEvent:Connect(function(hexCrystalsNeeded)
	
	localPlayer.PlayerGui.MainGUI.NotEnoughHexCrystals.Visible = true
	

	
	localPlayer.PlayerGui.MainGUI.NotEnoughHexCrystals.TextLabel.Text = "You need "..hexCrystalsNeeded.." Hex Crystals more to buy this"
	if hexCrystalsNeeded <= 100 then
		promptPurchase(localPlayer,crystalsID["100"])
	elseif hexCrystalsNeeded <= 500 then
		promptPurchase(localPlayer,crystalsID["500"])
	elseif hexCrystalsNeeded <= 750 then
		promptPurchase(localPlayer, crystalsID["750"])	
	elseif hexCrystalsNeeded <= 1000 then
		promptPurchase(localPlayer,crystalsID["1000"])
	elseif hexCrystalsNeeded <= 2500 then
		promptPurchase(localPlayer,crystalsID["2500"])	
	elseif hexCrystalsNeeded <= 5000 then
		promptPurchase(localPlayer,crystalsID["5000"])
	end
end)


localPlayer.PlayerGui.MainGUI.NotEnoughHexCrystals.Close.MouseButton1Click:connect(function()
			localPlayer.PlayerGui.MainGUI.NotEnoughHexCrystals.Visible = false
end)