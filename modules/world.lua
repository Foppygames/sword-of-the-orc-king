-- world is a module that manages and displays the current game world

local aspect = require("modules.aspect")
local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local layout = require("modules.layout")
local renderSystem = require("modules.ecs.systems.rendersystem")
local tiles = require("modules.tiles")

local world = {}

local BACKGROUND_COLOR = colors.get("BLACK")
local LEVELS = 3
local STARTING_LEVEL = 1
local TILE_WIDTH = 16
local TILE_HEIGHT = 24
local WORLD_WIDTH = 20
local WORLD_HEIGHT = 20
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

function world.createNew(levels,startingLevel)	
	local levels = (levels or LEVELS)
	local startingLevel = (startingLevel or STARTING_LEVEL)
	state = {}
	for i = 1, levels do
		local addHero = (i == startingLevel)
		world.addLevel(addHero)
	end
end

function world.addLevel(addHero)
	-- add empty level to state
	table.insert(state,{
		layout = {}, -- contains map and stored actors per location
		actors = {}  -- contains active actors for whole level
	})

	local tempRoomWidth = WORLD_WIDTH
	local tempRoomHeight = WORLD_HEIGHT

	-- create level layout
	local level = #state
	for y = 1, WORLD_HEIGHT do
		for x = 1, WORLD_WIDTH do
			local wall = 0
			local floor = 0
			local tile = nil

			if (((x == 1 ) or (x == tempRoomWidth)) and (y <= tempRoomHeight)) then
				wall = 1
			end
			if (((y == 1) or (y == tempRoomHeight)) and (x <= tempRoomWidth)) then
				wall = 1
			end
			if ((x > tempRoomWidth*0.25) and (x < tempRoomWidth*0.75)) then
				if ((y > tempRoomHeight*0.25) and (y < tempRoomHeight*0.75)) then
					wall = 1
				end
			end
			if ((x > 1 ) and (x < tempRoomWidth) and (y > 1 ) and (y < tempRoomHeight)) then
				floor = 1
			end

			if (wall == 1) then
				tile = "wallFront"
			elseif (floor == 1) then
				tile = "floor"
			end

			-- add item for position
			table.insert(state[level].layout,{
				wall = wall,
				floor = floor,
				actor = nil,
				tile = tile
			})

			-- convert wall tiles if front blocked from view
			if (tile == "wallFront") then
				if (y > 1) then
					local posAboveIndex = (y - 2) * WORLD_WIDTH + x
					local item = state[level].layout[posAboveIndex]
					if (item ~= nil) then
						if (item.tile == "wallFront") then
							state[level].layout[posAboveIndex].tile = "wallTop"
						end
					end
				end
			end
		end
	end

	-- add hero and bat
	if (addHero) then
		local x = 3
		local y = 3
		local posIndex = (y - 1) * WORLD_WIDTH + x

		state[level].layout[posIndex].actor = {
			type = "hero",
			data = {
				position = {
					x = x,
					y = y,
					z = level
				}
			}
		}

		x = 5
		y = 3
		posIndex = (y - 1) * WORLD_WIDTH + x

		state[level].layout[posIndex].actor = {
			type = "bat",
			data = {
				position = {
					x = x,
					y = y,
					z = level
				}
			}
		}
	end
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