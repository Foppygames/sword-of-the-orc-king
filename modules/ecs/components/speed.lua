local Component = require("modules.ecs.components.component")

local Speed = {}

function Speed.create(entityDefaults,entityData)
    local self = Component.create({
        delayAfterAction = 3,
        delayRemaining = 0
    })

    --[[
    Note: delayAfterAction is 3 by default. This will be the speed of the player. To make a bat move three
    times as fast as the player, this value should be 1 for the bat. Each turn, a bat will make a move, while
    only after three turns, the hero will be able to make a move.

    It may seem more logical to set the default to 1, however this would mean the bat would need to get a fractional
    value of 1/3, which could lead to inaccuracies. This approach means that a setting of 1 is the lowest possible
    value (0 cannot be used) and the highest speed.
    ]]

    self.setValues(entityDefaults,entityData)

    return self
end

return Speed