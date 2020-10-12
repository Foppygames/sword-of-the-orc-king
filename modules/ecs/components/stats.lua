-- entity has stats: stats influence actions performed by and on entity

local Component = require("modules.ecs.components.component")

local Stats = {}

function Stats.create(entityDefaults,entityData)
    local self = Component.create({
        health = 1,
        healthMax = 1,
        rest = false,
        healthIncrement = 1,
        strength = 1
    })

    self.setValues(entityDefaults,entityData)

    return self
end

return Stats