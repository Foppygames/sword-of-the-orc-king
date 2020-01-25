-- entitymanager is a module managing entity definitions and the collection of active entities

local entityManager = {}

local definitions = {
	bat = require("modules.ecs.entities.bat"),
	hero = require("modules.ecs.entities.hero")
}

local entities = {}

function entityManager.reset()
	entities = {}
end

function entityManager.addEntity(id,data)
	table.insert(entities,definitions[id].create(data))
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