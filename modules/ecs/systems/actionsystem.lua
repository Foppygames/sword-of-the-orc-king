local actionManager = require("modules.ecs.managers.actionmanager")
local entityManager = require("modules.ecs.managers.entitymanager")
local energySystem = require("modules.ecs.systems.energysystem")
local input = require("modules.input")
local world = require("modules.world")

local actionSystem = {}

local queue = {}
local backlog = {}

function actionSystem.reset()
	queue = {}
	backlog = {}
end

-- returns true if all entities have been processed, false otherwise
local function removeLastFromQueue()
	table.remove(queue,#queue)
	if (#queue == 0) then
		if (#backlog > 0) then
			queue = backlog
			backlog = {}
			return false
		else
			return true
		end
	end
end

-- updates the next entity and returns true if all entities updated, false otherwise
function actionSystem.update(inputAction)
	-- set of entities needs to be fetched
	if (#queue == 0) then
		queue = entityManager.getEntitiesHaving({"action","energy"})
		backlog = {}
	end

	-- no entities found
	if (#queue == 0) then
		return true
	end

	local redraw = false
	local allUpdated = false

	while not(redraw or allUpdated) do
		-- get last entity
		local entity = queue[#queue]

		-- energy available for action
		if (entity.energy.level >= energySystem.ENERGY_FOR_ACTION) then
			local action = nil
			local result = {
				success = false,
				newAction = nil
			}

			if (entityManager.entityHas(entity,{"ai"})) then
				action = actionSystem.getAiAction(entity)
			elseif (entityManager.entityHas(entity,{"input"})) then
				action = inputAction
			else
				action = actionManager.createAction("skip")
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
				-- redraw if action changes visible world or interface in any way
				-- ...
				
				--redraw = true

				entity.energy.level = entity.energy.level - energySystem.ENERGY_FOR_ACTION
				if (entity.energy.level >= energySystem.ENERGY_FOR_ACTION) then
					-- add entity to backlog
					table.insert(backlog,entity)
				end
				-- remove entity from queue
				if (removeLastFromQueue()) then
					allUpdated = true
				end
			-- no successful action
			else
				-- stay in this entity's turn
				redraw = true
			end
		-- no energy available for action
		else
			-- remove entity from queue
			if (removeLastFromQueue()) then
				allUpdated = true
			end
		end
	end

	return allUpdated
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