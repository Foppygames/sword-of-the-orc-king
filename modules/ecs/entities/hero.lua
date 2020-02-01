local Entity = require("modules.ecs.entities.entity")

local Hero = {}

function Hero.create(data)
    return Entity.create({
        action = {},
		appearance = {
			imageId = "hero"
		},
		attack = {},
		camera = {},
		energy = {
			increment = 5
		},
		input = {},
		movement = {},
		position = {}
    },data)
end

return Hero