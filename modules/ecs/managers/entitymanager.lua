-- entitymanager is a module managing the collection of active entities

local entityManager = {}

-- available components
local components = {
	action = require("modules.ecs.components.action"),
	appearance = require("modules.ecs.components.appearance"),
	camera = require("modules.ecs.components.camera"),
	energy = require("modules.ecs.components.energy"),
	input = require("modules.ecs.components.input"),
	movement = require("modules.ecs.components.movement"),
	position = require("modules.ecs.components.position"),
	-- vision = ... (component allowing entity to see tiles and entities on tiles, to help decide next action)
}

-- available entity types defined in terms of components and entity default component values
local configs = {
	bat = {
		action = {},
		appearance = {
			imageId = "bat"
		},
		energy = {
			increment = 10
		},
		movement = {},
		position = {}
	},
	hero = {
		action = {},
		appearance = {
			imageId = "orc"
		},
		camera = {},
		energy = {
			increment = 5
		},
		input = {},
		movement = {},
		position = {}
	}
}

local entities = {}

function entityManager.reset()
	entities = {}
end

function entityManager.addEntity(id,entityData)
	local entity = {}
	local config = configs[id]
	for componentId,entityDefaults in pairs(config) do
		entity[componentId] = entityManager.createComponent(componentId,entityDefaults,entityData[componentId])
	end
	table.insert(entities,entity)
end

function entityManager.createComponent(id,entityDefaults,entityData)
	return components[id].create(entityDefaults,entityData)
end

function entityManager.getEntitiesHaving(componentIds)
	local result = {}
	for i = 1, #entities do
		local success = true
		for j = 1, #componentIds do
			local componentId = componentIds[j]
			if (entities[i][componentId] == nil) then
				success = false
				break
			end
		end
		if (success) then
			table.insert(result,entities[i])
		end
	end
	return result
end

function entityManager.entityHas(entity,componentIds)
	for j = 1, #componentIds do
		local componentId = componentIds[j]
		if (entity[componentId] == nil) then
			return false
		end
	end
	return true
end

function entityManager.getFirstCameraEntityPosition()
	local entities = entityManager.getEntitiesHaving({"camera","position"})
	if (#entities > 0) then
		return entities[1].position
	end
	return nil
end

return entityManager