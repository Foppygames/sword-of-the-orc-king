local Entity = require("modules.ecs.entities.entity")

local Bat = {}

function Bat.create(data)
    return Entity.create({
        action = {},
		appearance = {
			imageId = "bat"
		},
		energy = {
			increment = 10
		},
		movement = {},
		position = {}
    },data)
end

return Bat