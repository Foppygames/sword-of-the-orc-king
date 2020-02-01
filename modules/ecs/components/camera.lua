local Component = require("modules.ecs.components.component")

local Camera = {}

function Camera.create(entityDefaults,entityData)
    local self = Component.create({})

    self.setValues(entityDefaults,entityData)

    return self
end

return Camera