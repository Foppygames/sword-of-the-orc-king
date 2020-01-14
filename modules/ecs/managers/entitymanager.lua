-- entitymanager is a module managing the collection of active entities

local entityManager = {}

-- available components
local components = {
	appearance = require("modules.ecs.components.appearance"),
	energy = require("modules.ecs.components.energy"),
	movement = require("modules.ecs.components.movement"),
	position = require("modules.ecs.components.position"),
	-- vision = ... (component allowing entity to see tiles and entities on tiles, to help decide next action)
}

-- available entity types defined in terms of components and entity default component values
local configs = {
	bat = {
		appearance = {
			size = 8,
			color = {0,0,1}
		},
		energy = {
			increment = 10
		},
		movement = {},
		position = {}
	},
	hero = {
		appearance = {
			size = 16,
			color = {0,1,0}
		},
		energy = {
			increment = 5
		},
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

return entityManager