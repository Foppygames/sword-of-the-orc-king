local Entity = require("modules.ecs.entities.entity")

local Sword = {}

function Sword.create(data)
    return Entity.create({
        appearance = {
			imageId = "sword"
		},
		item = {
			wieldable = true
		},
		name = {
			genericName = "sword"
		},
		position = {}
	},data)
end

return Sword