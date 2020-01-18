local entityManager = require("modules.ecs.managers.entitymanager")
local energySystem = require("modules.ecs.systems.energysystem")
local world = require("modules.world")

local actionSystem = {}

function actionSystem.update()
	local entities = entityManager.getEntitiesHaving({"energy","movement","position"})
	for i = 1, #entities do
		-- energy for action available
		if (entities[i].energy.level >= energySystem.ENERGY_FOR_ACTION) then
			-- pick random direction, including none (dX = 0, dY = 0)
			local dX = math.random(-1,1)
			local dY = math.random(-1,1)

			if ((dX ~= 0) or (dY ~= 0)) then
				-- check new location
				local newX = entities[i].position.x + dX
				local newY = entities[i].position.y + dY

				if (world.locationIsPassable(newX,newY,entities[i].position.z)) then
					-- also check if no entity at location, using entityManager?
					-- ...

					entities[i].position.x = newX
					entities[i].position.y = newY
				end
			end

			-- use energy
			entities[i].energy.useForAction = true
		end
	end
end

return actionSystem