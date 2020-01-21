local entityManager = require("modules.ecs.managers.entitymanager")
local images = require("modules.images")

local renderSystem = {}

function renderSystem.update(viewPortData)
	love.graphics.setColor(1,1,1)
	local entities = entityManager.getEntitiesHaving({"appearance","position"})
	for i = 1, #entities do
		local tileX = entities[i].position.x
		local tileY = entities[i].position.y
		
		if (renderSystem.withinViewPortTileRange(tileX,tileY,viewPortData.firstTileX,viewPortData.firstTileY,viewPortData.lastTileX,viewPortData.lastTileY)) then
			local x = viewPortData.screenX1 + (tileX - viewPortData.firstTileX) * viewPortData.tileWidth
			local y = viewPortData.screenY1 + (tileY - viewPortData.firstTileY) * viewPortData.tileHeight
			local image = images.get(entities[i].appearance.imageId)
			love.graphics.draw(image,x,y)
		end
	end
end

function renderSystem.withinViewPortTileRange(x,y,x1,y1,x2,y2)
	if ((x < x1) or (x > x2)) then
		return false
	end
	if ((y < y1) or (y > y2)) then
		return false
	end
	return true
end

return renderSystem