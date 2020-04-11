local Entity = require("modules.ecs.entities.entity")

local Bat = {}

function Bat.create(data)
    return Entity.create({
        action = {},
		ai = {},
		appearance = {
			imageId = "bat"
		},
		attack = {},
		energy = {
			increment = 2
		},
		movement = {},
		name = {
			genericName = "bat"
		},
		position = {},
		vision = {}
    },data)
end

return Bat