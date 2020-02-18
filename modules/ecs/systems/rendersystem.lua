local entityManager = require("modules.ecs.managers.entitymanager")
local images = require("modules.images")
local layout = require("modules.layout")

local renderSystem = {}

function renderSystem.update(viewPortData,visibleLocations)
	love.graphics.setColor(1,1,1)
	layout.enableClipping(viewPortData.rect)
	local entities = entityManager.getEntitiesHaving({"appearance","position"})
	for i = 1, #entities do
		local tileX = entities[i].position.x
		local tileY = entities[i].position.y
		
		if (renderSystem.withinViewPortTileRange(tileX,tileY,viewPortData.firstTileX,viewPortData.firstTileY,viewPortData.lastTileX,viewPortData.lastTileY)) then
			if (renderSystem.onVisibleLocation(tileX,tileY,entities[i].position.z,visibleLocations)) then
				local x = viewPortData.screenX1 + (tileX - viewPortData.firstTileX) * viewPortData.tileWidth
				local y = viewPortData.screenY1 + (tileY - viewPortData.firstTileY) * viewPortData.tileHeight
				local image = images.get(entities[i].appearance.imageId)

				-- Note: assuming all images are of same size as tiles
				love.graphics.draw(image,x,y)
			end
		end
	end
	layout.disableClipping()
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

function renderSystem.onVisibleLocation(x,y,z,visibleLocations)
	if (visibleLocations[z] == nil) then
		return false
	end
	if (visibleLocations[z][y] == nil) then
		return false
	end
	return (visibleLocations[z][y][x] ~= nil)
end

return renderSystem