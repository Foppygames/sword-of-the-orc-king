-- componentmanager is a module managing component definitions

local componentManager = {}

local definitions = {
	action = require("modules.ecs.components.action"),
	appearance = require("modules.ecs.components.appearance"),
	camera = require("modules.ecs.components.camera"),
	energy = require("modules.ecs.components.energy"),
	input = require("modules.ecs.components.input"),
	movement = require("modules.ecs.components.movement"),
	position = require("modules.ecs.components.position")
}

function componentManager.createComponent(id,entityDefaults,entityData)
	return definitions[id].create(entityDefaults,entityData)
end

return componentManager