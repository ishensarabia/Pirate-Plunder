--Services
local CollectionService = game:GetService("CollectionService")
--Classes
local HomeBase = require(game.ReplicatedStorage.Common.OOP.HomeBase)
local Cannon = require(game.ReplicatedStorage.Common.OOP.Cannon)
local Boat = require(game.ReplicatedStorage.Common.OOP.Boat)

Boat:InitializeObject()
HomeBase:InitializeObject()
Cannon:InitializeObject()



