local Component = require("modules.ecs.components.component")

local Appearance = {}

function Appearance.create(entityDefaults,entityData)
    local self = Component.create({
        size = 0,
        color = {0,0,0}
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Appearance