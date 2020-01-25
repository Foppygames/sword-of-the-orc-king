-- actionmanager is a module managing action definitions

local actionManager = {}

local definitions = {
	move = {
		dX = 0,
		dY = 0
	}
}

function componentManager.createComponent(id,entityDefaults,entityData)
	return definitions[id].create(entityDefaults,entityData)
end

function actionManager.createAction(id,data)
	local action = {}
	local definition = definitions[id]
	for property,default in pairs(definition) do
		if (data[property] ~= nil) then
			action[property] = data[property]
		else
			action[property] = default
		end
	end
	return action
end

return actionManager