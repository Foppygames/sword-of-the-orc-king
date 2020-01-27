-- input is a module managing aspects of player input leading to actions

local actionManager = require("modules.ecs.managers.actionmanager")

local input = {}

local action = nil

function input.resetAction()
	action = nil
end

function input.getAction()
	return action
end

function input.registerKeyPressed(key)
	-- Todo: create key equivalence groups leading to actions (via specialized functions)
	-- Todo: allow player to move diagonally, options: num keypad, mouse
	if (key == "up") then
		action = actionManager.createAction("move",{
			dY = -1
		})
	elseif (key == "down") then
		action = actionManager.createAction("move",{
			dY = 1
		})
	elseif (key == "left") then
		action = actionManager.createAction("move",{
			dX = -1
		})
	elseif (key == "right") then
		action = actionManager.createAction("move",{
			dX = 1
		})
	end
end

return input