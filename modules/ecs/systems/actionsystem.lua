local actionManager = require("modules.ecs.managers.actionmanager")
local entityManager = require("modules.ecs.managers.entitymanager")
local energySystem = require("modules.ecs.systems.energysystem")
local input = require("modules.input")
local world = require("modules.world")

local actionSystem = {}

local index = nil
local entities = {}

function actionSystem.reset()
	index = nil
	entities = {}
end

-- updates the next entity and returns true if all entities updated, false otherwise
function actionSystem.update(inputAction)
	-- set of entities needs to be fetched
	if (index == nil) then
		entities = entityManager.getEntitiesHaving({"action","energy"})
		index = math.min(1,#entities)
	end

	-- no entities found
	if (index == 0) then
		index = nil
		return true
	end

	-- all entities updated
	if (index > #entities) then
		index = nil
		return true
	end

	local entity = entities[index]
	local continue = true
	local action = nil
	local result = {
		success = false,
		newAction = nil
	}
	
	local energyForActionAvailable = (entity.energy.level >= energySystem.ENERGY_FOR_ACTION)

	if (energyForActionAvailable) then
		-- entity is controlled by ai
		if (entityManager.entityHas(entity,{"ai"})) then
			action = actionSystem.getAiAction(entity)
		-- entity is controlled by input
		elseif (entityManager.entityHas(entity,{"input"})) then
			action = inputAction
		-- entity is not controlled
		else
			action = actionManager.createAction("skip")
		end
	end
		
	-- action selected
	if (action ~= nil) then
		result = action.perform(entity)

		while (result.newAction ~= nil) do
			local newAction = actionManager.createAction(result.newAction.id,result.newAction.data)
			result = newAction.perform(entity)
		end
	end

	-- action performed with success
	if (result.success) then
		entity.energy.useForAction = true
	-- no successful action, while energy available
	elseif (energyForActionAvailable) then
		-- stay in this entity's turn
		continue = false
	end
	
	if (continue) then
		index = index + 1
	end

	return false
end

function actionSystem.getAiAction(entity)
	-- consider attacking
	-- ...

	-- consider moving
	if (entityManager.entityHas(entity,{"movement"})) then
		-- move in random direction
		return actionManager.createAction("move",{
			dX = math.random(-1,1),
			dY = math.random(-1,1)
		})
	end

	return actionManager.createAction("skip")
end

return actionSystem