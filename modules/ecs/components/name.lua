local Component = require("modules.ecs.components.component")

local Name = {}

function Name.create(entityDefaults,entityData)
    local self = Component.create({
        genericName = "unknown",
        specificName = nil
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Name