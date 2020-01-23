-- world is a module that manages and displays the current game world

local aspect = require("modules.aspect")
local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local layout = require("modules.layout")
local tiles = require("modules.tiles")

local world = {}

local BACKGROUND_COLOR = colors.get("BLACK")
local TILE_COLOR_FLOOR = colors.get("DARK_GREY")
local TILE_COLOR_WALL_FRONT = colors.get("BROWN")
local TILE_COLOR_WALL_TOP = colors.get("ORANGE")
local TILE_WIDTH = 16
local TILE_HEIGHT = 24
local WALL_HEIGHT = TILE_HEIGHT / 2
local WORLD_WIDTH = 50
local WORLD_HEIGHT = 50
local WORLD_DEPTH = 10

local cameraTileX = nil
local cameraTileY = nil
local cameraTileZ = nil
local state = {}
local rect
local rectHeightTiles
local rectWidthTiles

local function drawFloor(x,y)
	love.graphics.setColor(TILE_COLOR_FLOOR)
	love.graphics.rectangle("fill",x+TILE_WIDTH/2-1,y+TILE_HEIGHT/2-1,2,2)
end

local function drawWall(x,y,wallBelow)
	love.graphics.setColor(TILE_COLOR_WALL_TOP)
	love.graphics.rectangle("fill",x,y,TILE_WIDTH,TILE_HEIGHT)
	if (not wallBelow) then
		love.graphics.setColor(TILE_COLOR_WALL_FRONT)
		love.graphics.rectangle("fill",x,y+TILE_HEIGHT-WALL_HEIGHT,TILE_WIDTH,WALL_HEIGHT)
	end	
end

-- turn active actors into stored actors
local function storeActors(level)
	-- ...
end

-- turn stored actors into active actors
local function createActors(level)
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

function world.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
	rectWidthTiles = math.floor(rect.width / TILE_WIDTH) + 2
	rectHeightTiles = math.floor(rect.height / TILE_HEIGHT) + 2
end

function world.createNew(levels,startingLevel)		
	state = {}
	for i = 1, levels do
		local addHero = (i == startingLevel)
		world.addLevel(addHero)
	end
	cameraTileX = nil
	cameraTileY = nil
	cameraTileZ = nil
end

function world.addLevel(addHero)
	-- add empty level to state
	table.insert(state,{
		layout = {}, -- contains map and stored actors per location
		actors = {}  -- contains active actors for whole level
	})

	local tempRoomWidth = #state * 10
	local tempRoomHeight = #state * 10

	-- create level layout
	local level = #state
	for y = 1, WORLD_HEIGHT do
		for x = 1, WORLD_WIDTH do
			-- decide if position has wall, floor, or neither
			local wall = 0
			local floor = 0
			
			if (((x == 1 ) or (x == tempRoomWidth)) and (y <= tempRoomHeight)) then
				wall = 1
			end
			if (((y == 1) or (y == tempRoomHeight)) and (x <= tempRoomWidth)) then
				wall = 1
			end
			if ((x == tempRoomWidth/2) and (y == tempRoomHeight/2)) then
				wall = 1
			end
			if ((x > 1 ) and (x < tempRoomWidth) and (y > 1 ) and (y < tempRoomHeight)) then
				floor = 1
			end
			
			-- add item for position
			table.insert(state[level].layout,{
				wall = wall,
				floor = floor,
				actor = nil
			})
		end
	end

	-- add hero and at
	if (addHero) then
		local x = 3
		local y = 3
		local posIndex = (y - 1) * WORLD_WIDTH + x

		state[level].layout[posIndex].actor = {
			type = "hero",
			data = {
				appearance = {
					color = {0,1,0}
				},
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

function world.setCamera(x,y,z)
	if (x ~= nil) then
		cameraTileX = x
	end
	if (y ~= nil) then
		cameraTileY = y
	end
	if (z ~= nil) then
		local oldZ = cameraTileZ
		if ((oldZ ~= nil) and (oldZ ~= z)) then
			storeActors(oldZ)
		end
		if (oldZ ~= z) then
			createActors(z)
		end
		cameraTileZ = z
	end
end

function world.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)

	local viewPortData = world.getViewPortData()
	
	local tileY = viewPortData.screenY1
	for verTile = viewPortData.firstTileY, viewPortData.lastTileY do
		local tileX = viewPortData.screenX1
		for horTile = viewPortData.firstTileX, viewPortData.lastTileX do
			if ((horTile >= 1) and (verTile >= 1)) then
				local posIndex = (verTile - 1) * WORLD_WIDTH + horTile
				local wall = (state[cameraTileZ].layout[posIndex].wall == 1)
				local floor = (state[cameraTileZ].layout[posIndex].floor == 1)
				if (wall) then
					local wallBelow = false
					if (verTile < WORLD_HEIGHT) then
						if (state[cameraTileZ].layout[posIndex+WORLD_WIDTH].wall == 1) then
							wallBelow = true
						end
					end
					drawWall(tileX,tileY,wallBelow)
				elseif (floor) then
					drawFloor(tileX,tileY)
				end
			end
			tileX = tileX + TILE_WIDTH
		end
		tileY = tileY + TILE_HEIGHT
	end

	layout.disableClipping()
end

-- returns data for drawing world and entities within viewport
function world.getViewPortData()
	-- pixel location of camera in world
	local cameraX = cameraTileX * TILE_WIDTH - TILE_WIDTH / 2
	local cameraY = cameraTileY * TILE_HEIGHT - TILE_HEIGHT / 2

	-- upper left corner pixel location of viewport centered around camera
	local viewPortX1 = cameraX - rect.width / 2
	local viewPortY1 = cameraY - rect.height / 2

	-- top left viewport tile
	local firstTileX = 1 + math.floor(viewPortX1 / TILE_WIDTH)
	local firstTileY = 1 + math.floor(viewPortY1 / TILE_HEIGHT)
	
	-- pixel offset of upper left tile from viewport
	local offsetX = -viewPortX1 % TILE_WIDTH
	local offsetY = -viewPortY1 % TILE_HEIGHT
	
	-- bottom right viewport tile
	local lastTileX = math.min(firstTileX + rectWidthTiles - 1, WORLD_WIDTH)
	local lastTileY = math.min(firstTileY + rectHeightTiles - 1, WORLD_HEIGHT)
	
	return {
		screenX1 = rect.x + offsetX,
		screenY1 = rect.y + offsetY,
		firstTileX = firstTileX,
		firstTileY = firstTileY,
		lastTileX = lastTileX,
		lastTileY = lastTileY,
		tileWidth = TILE_WIDTH,
		tileHeight = TILE_HEIGHT
	}
end

function world.load()
	-- ...
end

function world.save()
	-- ...
end

function world.locationIsPassable(x,y,z)
	-- location is outside of world bounds
	if ((x < 1) or (x > WORLD_WIDTH)) then
		return false
	end
	if ((y < 1) or (y > WORLD_HEIGHT)) then
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

return world