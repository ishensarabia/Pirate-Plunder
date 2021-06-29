local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Services
local CollectionService = game:GetService("CollectionService")

local Boat = Object.new("Boat")
--local Boat = Object.newExtends("Boat",?)

local Boats = {}

function Boat.new(boat)
	local obj = Boat:make()
	--local obj = Boat:super()
	obj.StartingPosition = boat.PrimaryPart.Position
	obj.Model = boat
	obj.Seat = boat.Drive
	obj.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if not obj.Seat.Occupant then
			spawn(function()
				while wait(30) do
					if not obj.Seat.Occupant then
						obj:Respawn()
					end
				end
			end)
		end	
	end)

	return obj
end

function Boat:RespawnAllBoats()
	for index, boatClass in ipairs(Boats) do
		boatClass:Respawn()
	end
end

function Boat:Respawn()
	print("Respawning boat")
	self.Model:MoveTo(self.StartingPosition)
end

function Boat:InitializeObject()
	for index, boat in pairs(CollectionService:GetTagged("Boat")) do
		local newBoat = Boat.new(boat)
		table.insert(Boats, newBoat)
		
	end
end

return Boat