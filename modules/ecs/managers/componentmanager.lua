-- componentmanager is a module managing component definitions

local componentManager = {}

local definitions = {
	action = require("modules.ecs.components.action"),
	ai = require("modules.ecs.components.ai"),
	appearance = require("modules.ecs.components.appearance"),
	attack = require("modules.ecs.components.attack"),
	camera = require("modules.ecs.components.camera"),
	energy = require("modules.ecs.components.energy"),
	equipment = require("modules.ecs.components.equipment"),
	health = require("modules.ecs.components.health"),
	input = require("modules.ecs.components.input"),
	inventory = require("modules.ecs.components.inventory"),
	item = require("modules.ecs.components.item"),
	movement = require("modules.ecs.components.movement"),
	name = require("modules.ecs.components.name"),
	position = require("modules.ecs.components.position"),
	strength = require("modules.ecs.components.strength"),
	vision = require("modules.ecs.components.vision")
}

function componentManager.createComponent(id,entityDefaults,entityData)
	return definitions[id].create(entityDefaults,entityData)
end

return componentManager