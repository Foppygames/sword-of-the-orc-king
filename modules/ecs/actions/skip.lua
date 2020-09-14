local Action = require("modules.ecs.actions.action")
local entityManager = require("modules.ecs.managers.entitymanager")
local log = require("modules.log")

local Skip = {}

function Skip.create(data)
    local self = Action.create({})

    self.setValues(data)

    function self.perform(entity)
        -- show message to player
        if (entityManager.entityHas(entity,{"input"})) then
            log.addEntry("You rest for a moment.")
        end

        -- resting restores health
        if (entityManager.entityHas(entity,{"health"})) then
            entity.health.rest = true
        end

        return self.getPerformResult(true)
    end

    return self
end

return Skip