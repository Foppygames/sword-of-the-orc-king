local Action = require("modules.ecs.actions.action")
local componentManager = require("modules.ecs.managers.componentmanager")
local entityManager = require("modules.ecs.managers.entitymanager")
local Equipment = require("modules.ecs.components.Equipment")
local grammar = require("modules.grammar")
local log = require("modules.log")

local Takeoff = {}

function Takeoff.create(data)
    local self = Action.create({
        item = nil
    })

    self.setValues(data)

    function self.perform(entity)
        local success = false
        if (entityManager.entityHas(entity,{"equipment"})) then
            if entityManager.entityHas(self.item,{"item"}) and (self.item.item.wieldable) then
                -- look for slot containing item
                local slotIndex = nil
                for i = 1, #entity.equipment.items do
                    if (entity.equipment.items[i] == self.item) then
                        slotIndex = i
                        break
                    end
                end

                if (slotIndex ~= nil) then
                    -- add to inventory
                    table.insert(entity.inventory.items,self.item)

                    -- remove item from equipment
                    entity.equipment.items[slotIndex] = Equipment.NULL

                    log.addEntry(grammar.interpolate(grammar.STRUCT_E1_TAKE_OFF_E2,{entity,self.item}))
                    success = true
                else
                    -- consider swapping with item currently in wield slot
                    -- ...
                end
            
                if (not success) then
                    -- skip turn if not controlled by player
                    if (not entityManager.entityHas(entity,{"input"})) then
                        success = true
                    else
                        --log.addEntry("[No free slots available]")
                    end
                end
            end
        end    
        return self.getPerformResult(success)
    end

    return self
end

return Takeoff