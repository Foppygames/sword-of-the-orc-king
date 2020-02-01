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
            -- ...

            if (entityManager.entityHas(entity,{"input"})) then
                log.addEntry("You attack!")
            end

            success = true
        end
        return self.getPerformResult(success)
    end

    return self
end

return Attack