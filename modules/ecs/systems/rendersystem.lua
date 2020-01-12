local entityManager = require("modules.ecs.managers.entitymanager")

local renderSystem = {}

function renderSystem.render(viewPortData)
	local entities = entityManager.getEntitiesHaving({"appearance","position"})
	for i = 1, #entities do
		local tileX = entities[i].position.x
		local tileY = entities[i].position.y
		
		if (renderSystem.withinViewPortTileRange(tileX,tileY,viewPortData.firstTileX,viewPortData.firstTileY,viewPortData.lastTileX,viewPortData.lastTileY)) then
			local cX = viewPortData.screenX1 + (tileX - viewPortData.firstTileX) * viewPortData.tileWidth + viewPortData.tileWidth / 2
			local cY = viewPortData.screenY1 + (tileY - viewPortData.firstTileY) * viewPortData.tileHeight + viewPortData.tileHeight / 2
			local size = entities[i].appearance.size
			love.graphics.setColor(entities[i].appearance.color)
			love.graphics.rectangle("fill",cX-size/2,cY-size/2,size,size)
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