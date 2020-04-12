-- entity has item: entity can be walked over, picked up, added to inventory

local Component = require("modules.ecs.components.component")

local Item = {}

function Item.create(entityDefaults,entityData)
    local self = Component.create({})

    self.setValues(entityDefaults,entityData)

    return self
end

return Item