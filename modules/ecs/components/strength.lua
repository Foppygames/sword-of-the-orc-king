-- entity has strength: strength influences effect of attack

local Component = require("modules.ecs.components.component")

local Strength = {}

function Strength.create(entityDefaults,entityData)
    local self = Component.create({
        level = 10
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Strength