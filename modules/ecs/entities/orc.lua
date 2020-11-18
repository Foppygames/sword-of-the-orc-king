local Entity = require("modules.ecs.entities.entity")

local Orc = {}

function Orc.create(data)
    return Entity.create({
        action = {},
		ai = {},
		appearance = {
			imageId = "orc"
		},
		attack = {},
		energy = {
			increment = 1
		},
		movement = {},
		name = {
			genericName = "orc"
		},
		position = {},
		stats = {
			health = 20,
			healthMax = 20,
			strength = 3,
			damage = 1
		},
		vision = {}
    },data)
end

return Orc