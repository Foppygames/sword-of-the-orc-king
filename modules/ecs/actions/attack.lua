local Action = require("modules.ecs.actions.action")
local entityManager = require("modules.ecs.managers.entitymanager")
local log = require("modules.log")
local world = require("modules.world")

local Attack = {}

function Attack.create(data)
    local self = Action.create({
        x = 0,
        y = 0
    })

    self.setValues(data)

    function self.perform(entity)
        local success = false
        if (entityManager.entityHas(entity,{"attack","position"})) then
            local target = entityManager.getEntityAtLocation(self.x,self.y)
            if (target ~= nil) then
                -- ...

                if (entityManager.entityHas(entity,{"input"})) then

                    -- Todo: "You" should also be the result of interpolation in log module

                    log.addEntry("You attack <1>.",{target})
                else
                    log.addEntry("Something attacks something.")
                end
            end

            success = true
        end
        return self.getPerformResult(success)
    end

    return self
end

return Attack