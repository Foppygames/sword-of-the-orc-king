local Action = require("modules.ecs.actions.action")
local componentManager = require("modules.ecs.managers.componentmanager")
local entityManager = require("modules.ecs.managers.entitymanager")
local grammar = require("modules.grammar")
local log = require("modules.log")
local world = require("modules.world")

local Drop = {}

function Drop.create(data)
    local self = Action.create({
        item = nil
    })

    self.setValues(data)

    function self.perform(entity)
        local success = false
        if (entityManager.entityHas(entity,{"inventory","position"})) then
            -- todo: look for empty floor position
            -- ...
            local emptyFloor = true

            if (emptyFloor) then
                -- todo: refactor entity definition so that entity component defaults can be 
                -- retrieved separately and applied to component re-creation? (currently set to nil)
                -- ...

                -- create item position component
                self.item.position = componentManager.createComponent("position",nil,{
                    x = entity.position.x,
                    y = entity.position.y,
                    z = entity.position.z
                })

                -- remove from inventory
                for i = 1, #entity.inventory.items do
                    if (entity.inventory.items[i] == self.item) then
                        table.remove(entity.inventory.items,i)
                        break
                    end
                end
            
                log.addEntry(grammar.interpolate(grammar.STRUCT_E1_DROP_E2,{entity,self.item}))
                success = true
            end

            if (not success) then
                -- skip turn if not controlled by player
                if (not entityManager.entityHas(entity,{"input"})) then
                    success = true
                -- show message to player
                elseif (not emptyFloor) then
                    log.addEntry(grammar.interpolate(grammar.STRUCT_NO_PLACE_TO_DROP_E1,{self.item}))
                end
            end
        end    
        return self.getPerformResult(success)
    end

    return self
end

return Drop