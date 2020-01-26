local Action = require("modules.ecs.actions.action")
local entityManager = require("modules.ecs.managers.entityManager")
local world = require("modules.world")

local Move = {}

function Move.create(data)
    local self = Action.create({
        dX = 0,
        dY = 0
    })

    self.setValues(data)

    function self.run(entity)
        local success = false
        if (entityManager.entityHas(entity,{"movement","position"})) then
            -- target location is not entity location
            if ((self.dX ~= 0) or (self.dY ~= 0)) then
				-- check new location
				local newX = entity.position.x + self.dX
				local newY = entity.position.y + self.dY

                if (world.locationIsPassable(newX,newY,entity.position.z)) then
					-- also check if no entity at location, using entityManager and world
					-- ...

					entity.position.x = newX
					entity.position.y = newY

                    success = true
                else
                    -- skip turn if not controlled by player
                    if (not entityManager.entityHas(entity,{"input"})) then
                        success = true
                    end
                end
            -- target location is entity location
            else
                -- skip turn
                success = true
			end
        end
        return success
    end

    return self
end

return Move