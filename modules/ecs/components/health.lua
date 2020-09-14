-- entity has health: entity can die when health level reaches zero

local Component = require("modules.ecs.components.component")

local Health = {}

function Health.create(entityDefaults,entityData)
    local self = Component.create({
        level = 10,
        max = 10,
        rest = false,
        increment = 1
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Health