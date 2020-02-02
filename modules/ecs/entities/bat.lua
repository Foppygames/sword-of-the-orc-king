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
			increment = 10
		},
		movement = {},
		name = {
			genericName = "bat"
		},
		position = {}
    },data)
end

return Bat