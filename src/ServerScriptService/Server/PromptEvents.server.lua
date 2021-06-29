local ProximityPromptService = game:GetService("ProximityPromptService")
local ServerScriptService = game:GetService("ServerScriptService")
--Classes
local ChestClass = require(game.ReplicatedStorage.Common.OOP.Chest)
local CannonClass = require(game.ReplicatedStorage.Common.OOP.Cannon)
 

-- Detect when prompt is triggered
local function onPromptTriggered(promptObject, player)
    local object = promptObject:GetAttribute("Object")
    if object == "Chest" then
        local chestIndex = promptObject.Parent.Parent.Parent.Name
        local Chest = ChestClass:GetChest(chestIndex)

        Chest:PickUpChest(player)
    end  

    if object == "Cannon" then
        local Cannon = CannonClass:GetCannon(promptObject:GetAttribute("ID"))
        if not Cannon:CheckIsOccupied() then
            print("Cannon is not occupied")
            Cannon:SetOccupied(true,player)
        end
    end    
end
 


-- Detect when prompt hold begins
local function onPromptHoldBegan(promptObject, player)

end
 
-- Detect when prompt hold ends
local function onPromptHoldEnded(promptObject, player)

end
 
-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
ProximityPromptService.PromptButtonHoldBegan:Connect(onPromptHoldBegan)
ProximityPromptService.PromptButtonHoldEnded:Connect(onPromptHoldEnded)