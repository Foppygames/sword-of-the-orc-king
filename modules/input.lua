-- input is a module managing aspects of player input, especially in the context of the ecs

--[[
	If mouse or keyboard input or clicking of virtual buttons is detected anywhere in the program, it can be registered
	in this module. In the ecs, when player input is expected (for example in the actionsystem and when an entity has an
	input component), the input module can be questioned. (Maybe after first clearing the inputs already collected before
	they would have been relevant.)
]]

--[[
	Note: this may have to be changed so that this module is not simply about keyhits, but about actions. For example,
	instead of making a note that key up was pressed, it should note that an action "move" was ordered with dX = 0 and
	dY = -1. The fact that this was in some way done through an interface (keyboard, mouse clicks) can be handled somewhere
	else. (Maybe in an interface module.)

	No, wait. Actions should apply to all entities, but a module such as this one would typically apply only to the player.
	Also, something related to actions should be in the ecs, not among the general modules.
]]

local input = {}

input.KEY_UP_HIT = 1
input.KEY_DOWN_HIT = 2
input.KEY_LEFT_HIT = 3
input.KEY_RIGHT_HIT = 4
input.KEY_SPACE_HIT = 5

local event = nil

function input.reset()
	event = nil
end

function input.get()
	return event
end

function input.set(newEvent)
	event = newEvent
end

return input