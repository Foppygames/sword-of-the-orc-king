-- input is a module managing aspects of player input leading to actions

local actionManager = require("modules.ecs.managers.actionmanager")
local items = require("modules.items")

local input = {}

local DIRECTIONS = {
	up = {
		dY = -1
	},
	down = {
		dY = 1
	},
	left = {
		dX = -1
	},
	right = {
		dX = 1
	},
	kp8 = {
		dY = -1
	},
	kp9 = {
		dX = 1,
		dY = -1
	},
	kp6 = {
		dX = 1
	},
	kp3 = {
		dX = 1,
		dY = 1
	},
	kp2 = {
		dY = 1
	},
	kp1 = {
		dX = -1,
		dY = 1
	},
	kp4 = {
		dX = -1
	},
	kp7 = {
		dX = -1,
		dY = -1
	}
}

local action = nil
local listener = nil

-- returns action and new key listener
function input.defaultListener(key)
	local action = nil
	local newListener = nil
	
	if (DIRECTIONS[key] ~= nil) then
		action = actionManager.createAction("move",DIRECTIONS[key])
	elseif (key == "g") then
		action = actionManager.createAction("get")
	elseif (key == "i") then
		newListener = items.switchToState(items.STATE_INVENTORY)
	elseif (key == "space") then
		action = actionManager.createAction("skip")
	end
	
	return action, newListener
end

function input.getAction()
	return action
end

function input.resetAction()
	action = nil
end

function input.resetListener()
	listener = input.defaultListener
end

function input.registerKeyPressed(key)
	local newAction, newListener = listener(key)
	if (newAction ~= nil) then
		action = newAction
	end
	if (newListener ~= nil) then
		listener = newListener
	else
		listener = input.defaultListener
	end
end

return input