local Action = require("modules.ecs.actions.action")
local entityManager = require("modules.ecs.managers.entityManager")
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

        return true
    end

    return self
end

return Skip