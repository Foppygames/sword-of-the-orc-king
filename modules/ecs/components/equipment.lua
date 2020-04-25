-- entity has equipment: entity can wear/wield items

local Component = require("modules.ecs.components.component")

local Equipment = {}

-- value representing empty slot
Equipment.NULL = "null"

function Equipment.create(entityDefaults,entityData)
    local self = Component.create({
        -- Note: items contains wielded items followed by worn items
        -- Note: wieldSlots and wearSlots define number of slots per type by listing their names
        items = {},
        wearSlots = {},
        wieldSlots = {}
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Equipment