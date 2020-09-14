local entityManager = require("modules.ecs.managers.entitymanager")

local healthSystem = {}

function healthSystem.update()
	local entities = entityManager.getEntitiesHaving({"health"})
	for i = 1, #entities do
		if entities[i].health.level < entities[i].health.max then
			if entities[i].health.rest then
				entities[i].health.level = entities[i].health.level + entities[i].health.increment
				if entities[i].health.level > entities[i].health.max then
					entities[i].health.level = entities[i].health.max
				end
				entities[i].health.rest = false
			end
		end
	end
end

return healthSystem