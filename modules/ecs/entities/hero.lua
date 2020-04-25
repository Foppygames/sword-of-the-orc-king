local Entity = require("modules.ecs.entities.entity")
local Equipment = require("modules.ecs.components.equipment")

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
		equipment = {
			items = {Equipment.NULL},
			wieldSlots = {"hand"}
		},
		input = {},
		inventory = {},
		movement = {},
		position = {},
		vision = {}
    },data)
end

return Hero