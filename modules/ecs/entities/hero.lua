local Entity = require("modules.ecs.entities.entity")

local Hero = {}

-- Todo: use an actual orc entity that is somehow identified as the player / controlled by the player

function Hero.create(data)
    return Entity.create({
        action = {},
		appearance = {
			imageId = "orc"
		},
		camera = {},
		energy = {
			increment = 5
		},
		--input = {},
		movement = {},
		position = {}
    },data)
end

return Hero