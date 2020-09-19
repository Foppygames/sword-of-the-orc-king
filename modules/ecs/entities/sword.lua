local Entity = require("modules.ecs.entities.entity")
local Equipment = require("modules.ecs.components.equipment")

local Sword = {}

function Sword.create(data)
    return Entity.create({
        appearance = {
			imageId = "sword"
		},
		item = {
			wieldable = true,
			slotType = Equipment.SLOT_TYPE_MAIN_HAND
		},
		name = {
			genericName = "sword"
		},
		position = {},
		strength = {
			level = 1
		}
	},data)
end

return Sword