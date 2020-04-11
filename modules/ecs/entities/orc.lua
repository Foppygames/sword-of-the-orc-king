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
		vision = {}
    },data)
end

return Orc