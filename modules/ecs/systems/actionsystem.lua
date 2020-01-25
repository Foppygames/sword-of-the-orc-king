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

-- updates the next entity and returns two booleans: pause needed, all entities updated
function actionSystem.update(inputEvent)
	-- set of entities needs to be fetched
	if (index == nil) then
		--entities = entityManager.getEntitiesHaving({"energy","movement","position"})
		entities = entityManager.getEntitiesHaving({"action","energy"})
		-- note: perhaps make energy properties part of action component since one cannot exist without the other anyway
		index = math.min(1,#entities)
	end

	-- no entities found
	if (index == 0) then
		index = nil
		return false,true
	end

	-- all entities updated
	if (index > #entities) then
		index = nil
		return false,true
	end

	local energyForActionAvailable = (entities[index].energy.level >= energySystem.ENERGY_FOR_ACTION)
	
	local acted = false
	local continue = true

	if (energyForActionAvailable) then
		-- only considering movement for now
		if (entityManager.entityHas(entities[index],{"movement","position"})) then
			local dX = 0
			local dY = 0

			if (entityManager.entityHas(entities[index],{"input"})) then
				if (inputEvent ~= nil) then
					if (inputEvent == input.KEY_UP_HIT) then
						dY = -1
					elseif (inputEvent == input.KEY_DOWN_HIT) then
						dY = 1
					elseif (inputEvent == input.KEY_LEFT_HIT) then
						dX = -1
					elseif (inputEvent == input.KEY_RIGHT_HIT) then
						dX = 1
					end

					--[[
						Note: this seems to be the wrong approach. Maybe we want to talk about actions
						here instead of keyboard events. Just a single keyboard event as input to actionsystem
						update function is too low level? Player uses interface to construct (in one step or
						more steps) an action. This is then provided to this function. Computer entities
						construct an action using the actionsystem. (?)
					]]
				else
					continue = false
				end
			else
				dX = math.random(-1,1)
				dY = math.random(-1,1)
			end

			if ((dX ~= 0) or (dY ~= 0)) then
				-- check new location
				local newX = entities[index].position.x + dX
				local newY = entities[index].position.y + dY

				if (world.locationIsPassable(newX,newY,entities[index].position.z)) then
					-- also check if no entity at location, using entityManager and world
					-- ...

					entities[index].position.x = newX
					entities[index].position.y = newY

					-- action performed successfully
					acted = true
				end
			end
		else
			-- pass turn
			acted = true
		end

		if (acted) then
			entities[index].energy.useForAction = true
		end
	end

	if (continue) then
		index = index + 1
	end

	return acted,false
end

return actionSystem