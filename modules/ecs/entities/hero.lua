local Entity = require("modules.ecs.entities.entity")

local Hero = {}

function Hero.create(data)
    return Entity.create({
        action = {},
		appearance = {
			imageId = "human"
		},
		attack = {},
		camera = {},
		energy = {
			increment = 1
		},
		input = {},
		movement = {},
		position = {},
		vision = {}
    },data)
end

return Hero