local Action = require("modules.ecs.actions.action")
local entityManager = require("modules.ecs.managers.entitymanager")
local grammar = require("modules.grammar")
local log = require("modules.log")
local world = require("modules.world")

local Attack = {}

function Attack.create(data)
    local self = Action.create({
        x = 0,
        y = 0,
        z = 0
    })

    self.setValues(data)

    function self.perform(entity)
        local success = false
        if (entityManager.entityHas(entity,{"attack","position"})) then
            local target = entityManager.getEntityAtLocationNotHaving(self.x,self.y,self.z,{"item"})
            if (target ~= nil) then
                -- ...

                log.addEntry(grammar.interpolate(grammar.STRUCT_E1_ATTACK_E2,{entity,target}))
            end

            success = true
        end
        return self.getPerformResult(success)
    end

    return self
end

return Attack