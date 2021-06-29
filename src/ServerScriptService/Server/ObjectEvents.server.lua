--Events
local events =game.ReplicatedStorage.Common.CannonSystem.Remotes
local fireCannon = game.ReplicatedStorage.Common.CannonSystem.Remotes.FireCannon
--Classes
local CannonClass = require(game.ReplicatedStorage.Common.OOP.Cannon)

fireCannon.OnServerEvent:Connect(function(player, mousePosition)
    local Cannon = CannonClass:GetCannon(player:GetAttribute("CannonID"))
    Cannon:ShootCannon(mousePosition)
end)

events.LeaveCannon.OnServerEvent:Connect(function(player)
    if player:GetAttribute("CannonID") ~= nil then
        local Cannon = CannonClass:GetCannon(player:GetAttribute("CannonID"))
        Cannon:LeaveCannon()
    end
end)