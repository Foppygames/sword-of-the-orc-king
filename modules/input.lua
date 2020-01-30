-- input is a module managing aspects of player input leading to actions

local actionManager = require("modules.ecs.managers.actionmanager")

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

function input.resetAction()
	action = nil
end

function input.getAction()
	return action
end

function input.registerKeyPressed(key)
	if (DIRECTIONS[key] ~= nil) then
		action = actionManager.createAction("move",DIRECTIONS[key])
	elseif (key == "space") then
		action = actionManager.createAction("skip")
	end
end

return input