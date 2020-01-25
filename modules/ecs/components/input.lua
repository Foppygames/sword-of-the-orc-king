local Component = require("modules.ecs.components.component")

local Input = {}

function Input.create(entityDefaults,entityData)
    local self = Component.create({
        --event = nil
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Input