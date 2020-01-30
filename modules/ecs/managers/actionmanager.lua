-- actionmanager is a module managing action definitions

local actionManager = {}

local definitions = {
	move = require("modules.ecs.actions.move"),
	skip = require("modules.ecs.actions.skip")
}

function actionManager.createAction(id,data)
	return definitions[id].create(data)
end

return actionManager