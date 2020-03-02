-- world is a module that manages and displays the current game world

local aspect = require("modules.aspect")
local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local layout = require("modules.layout")
local map = require("modules.map")
local renderSystem = require("modules.ecs.systems.rendersystem")
local tiles = require("modules.tiles")

local world = {}

local BACKGROUND_COLOR = colors.get("BLACK")
local LEVELS = 3
local STARTING_LEVEL = 1
local TILE_WIDTH = 16
local TILE_HEIGHT = 16
local WORLD_WIDTH = 40
local WORLD_HEIGHT = 40
local WORLD_DEPTH = 10

local state = {}
local rect
local rectHeightTiles
local rectWidthTiles
local viewportCenterTileX = 1
local viewportCenterTileY = 1
local viewportZ = STARTING_LEVEL
local viewportVisibleLocations = {}

-- turn active actors into stored actors
function world.storeActors(level)
	-- ...
end

-- turn stored actors into active actors
function world.createActors(level)
	local level = (level or STARTING_LEVEL)
	for y = 1, WORLD_HEIGHT do
		for x = 1, WORLD_WIDTH do
			local posIndex = (y - 1) * WORLD_WIDTH + x
			local actor = state[level].layout[posIndex].actor
			if (actor ~= nil) then
				entityManager.addEntity(actor.type,actor.data)
			end
		end
	end
end

local function getViewportData()
	-- world pixel location of viewport center tile
	local cameraX = viewportCenterTileX * TILE_WIDTH - TILE_WIDTH / 2
	local cameraY = viewportCenterTileY * TILE_HEIGHT - TILE_HEIGHT / 2

	-- upper left corner pixel location of viewport centered around camera
	local viewportX1 = cameraX - rect.width / 2
	local viewportY1 = cameraY - rect.height / 2

	-- top left viewport tile
	local firstTileX = 1 + math.floor(viewportX1 / TILE_WIDTH)
	local firstTileY = 1 + math.floor(viewportY1 / TILE_HEIGHT)
	
	-- pixel offset of upper left tile from viewport
	local offsetX = viewportX1 % TILE_WIDTH
	local offsetY = viewportY1 % TILE_HEIGHT
	
	-- bottom right viewport tile
	local lastTileX = math.min(firstTileX + rectWidthTiles - 1, WORLD_WIDTH)
	local lastTileY = math.min(firstTileY + rectHeightTiles - 1, WORLD_HEIGHT)
	
	return {
		screenX1 = rect.x - offsetX,
		screenY1 = rect.y - offsetY,
		firstTileX = firstTileX,
		firstTileY = firstTileY,
		lastTileX = lastTileX,
		lastTileY = lastTileY,
		tileWidth = TILE_WIDTH,
		tileHeight = TILE_HEIGHT,
		rect = rect
	}
end

function world.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
	rectWidthTiles = math.floor(rect.width / TILE_WIDTH) + 2
	rectHeightTiles = math.floor(rect.height / TILE_HEIGHT) + 2
end

function world.createNew(levels)	
	local levels = (levels or LEVELS)
	state = {}
	for i = 1, levels do
		world.addLevel()
	end
end

function world.addLevel()
	local level = #state + 1
	-- each level contains a layout, including stored actors, and a set of active actors
	table.insert(state,{
		layout = map.createLayout(WORLD_WIDTH,WORLD_HEIGHT,level),
		actors = {}
	})
end

-- renders world layout and entities in viewport
function world.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)

	local viewportData = getViewportData()
	
	local tileY = viewportData.screenY1
	for verTile = viewportData.firstTileY, viewportData.lastTileY do
		local tileX = viewportData.screenX1
		for horTile = viewportData.firstTileX, viewportData.lastTileX do
			if ((horTile >= 1) and (verTile >= 1)) then
				local visible = false
				if (viewportVisibleLocations[viewportZ] ~= nil) then
					if (viewportVisibleLocations[viewportZ][verTile] ~= nil) then
						if (viewportVisibleLocations[viewportZ][verTile][horTile] ~= nil) then
							visible = true
						end
					end
				end
				local posIndex = (verTile - 1) * WORLD_WIDTH + horTile
				local tile = state[viewportZ].layout[posIndex].tile
				if (tile ~= nil) then
					tiles.draw(tile,tileX,tileY,visible)
				end
			end
			tileX = tileX + TILE_WIDTH
		end
		tileY = tileY + TILE_HEIGHT
	end

	layout.disableClipping()

	renderSystem.update(viewportData,viewportVisibleLocations)
end

function world.locationExists(x,y,z)
	if ((x < 1) or (x > WORLD_WIDTH)) then
		return false
	end
	if ((y < 1) or (y > WORLD_HEIGHT)) then
		return false
	end
	return true
end

function world.locationIsPassable(x,y,z)
	-- location is outside of world bounds
	if (not world.locationExists(x,y,z)) then
		return false
	end

	local posIndex = (y - 1) * WORLD_WIDTH + x

	-- location has wall
	if (state[z].layout[posIndex].wall == 1) then
		return false
	end

	-- passable if floor present
	return (state[z].layout[posIndex].floor == 1)
end

-- stores and creates actors if level change dictates it
local function processCameraEntityZ(cameraEntity)
	if ((viewportZ ~= nil) and (viewportZ ~= cameraEntity.position.z)) then
		world.storeActors(viewportZ)
	end
	if (viewportZ ~= cameraEntity.position.z) then
		world.createActors(cameraEntity.position.z)
	end
	return cameraEntity.position.z
end

-- updates viewport location and visible locations based on provided entity
function world.updateViewport(cameraEntity)
	if (cameraEntity ~= nil) then
		viewportCenterTileX = cameraEntity.position.x
		viewportCenterTileY = cameraEntity.position.y
		viewportZ = processCameraEntityZ(cameraEntity)
		viewportVisibleLocations = cameraEntity.vision.visible
	end
end

return world