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

	local acted = false
	local continue = true
	local action = nil
	
	local energyForActionAvailable = (entities[index].energy.level >= energySystem.ENERGY_FOR_ACTION)

	if (energyForActionAvailable) then
		-- entity is controlled by input
		if (entityManager.entityHas(entities[index],{"input"})) then
			-- use provided action
			action = inputAction
		-- entity is controlled by computer
		else
			-- move in random direction
			action = actionManager.createAction("move",{
				dX = math.random(-1,1),
				dY = math.random(-1,1)
			})
		end
	end
		
	-- action selected
	if (action ~= nil) then
		acted = action.perform(entities[index])
	end

	-- action performed with success
	if (acted) then
		entities[index].energy.useForAction = true
	-- no successful action, while energy available
	elseif (energyForActionAvailable) then
		-- stay in this entity's turn
		continue = false
		-- Todo: add explicit skip action so turn can be completed even though energy for action is available
	end
	
	if (continue) then
		index = index + 1
	end

	return false
end

return actionSystem