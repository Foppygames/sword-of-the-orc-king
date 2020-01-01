-- world is a module that manages and displays the current game world

local aspect = require("modules.aspect")
local layout = require("modules.layout")

local world = {}

local BACKGROUND_COLOR = {0.3,0.3,0.3}
local TILE_COLOR_FLOOR_1 = {0.12,0.12,0.12}
local TILE_COLOR_FLOOR_2 = {0.14,0.14,0.14}
local TILE_COLOR_WALL_FRONT = {0.2,0.2,0.2}
local TILE_COLOR_WALL_TOP = {0.3,0.3,0.3}
local TILE_PERSPECTIVE_FACTOR = 0.5
local TILE_SIZE = 26
local WALL_HEIGHT = TILE_SIZE * TILE_PERSPECTIVE_FACTOR
local WORLD_WIDTH = 50
local WORLD_HEIGHT = 50
local WORLD_DEPTH = 10

local cameraTileX
local cameraTileY
local cameraTileZ
local state = {}
local rect
local rectHeightTiles
local rectWidthTiles

local function drawFloor(color,x,y)
	love.graphics.setColor(color)
	love.graphics.rectangle("fill",x,y,TILE_SIZE,TILE_SIZE)
end

local function drawWall(x,y)
	love.graphics.setColor(TILE_COLOR_WALL_TOP)
	love.graphics.rectangle("fill",x,y-WALL_HEIGHT,TILE_SIZE,TILE_SIZE)
	love.graphics.setColor(TILE_COLOR_WALL_FRONT)
	love.graphics.rectangle("fill",x,y+TILE_SIZE-WALL_HEIGHT,TILE_SIZE,WALL_HEIGHT)
end

local function scroll()
	-- ...
end

function world.init(drawingAreaIndex)
	cameraTileX = 2
	cameraTileY = 2
	cameraTileZ = 1

	rect = layout.getRect(drawingAreaIndex)
	rectWidthTiles = math.floor(rect.width / TILE_SIZE) + 2
	rectHeightTiles = math.floor(rect.height / TILE_SIZE) + 2
	
	-- reset state
	state = {}

	-- add first level to state
	table.insert(state,{})

	-- add tile map to first level
	state[1].tiles = {}
	for y = 1, WORLD_HEIGHT do
		for x = 1, WORLD_WIDTH do
			local wall = 0
			if ((y - 1) % 8 == 0) or ((x - 1) % 8 == 0) then
				-- door north/south
				if ((y > 1) and (y < WORLD_HEIGHT) and ((y - 1) % 8 == 0) and (((x - 5) % 8 == 0))) then
					wall = 0
				-- door east/west	
				elseif ((x > 1) and (x < WORLD_WIDTH) and ((x - 1) % 8 == 0) and (((y - 5) % 8 == 0))) then
						wall = 0
				-- wall
				else
					wall = 1
				end
			end
			table.insert(state[1].tiles,wall)
		end
	end

	--for i = 1, #state[1].tiles do
	--	print(state[1].tiles[i]..", ")
	--end
end

function world.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)
	
	local cameraX = cameraTileX * TILE_SIZE - TILE_SIZE / 2
	local cameraY = cameraTileY * TILE_SIZE - TILE_SIZE / 2

	local viewPortX1 = cameraX - rect.width / 2
	local viewPortY1 = cameraY - rect.height / 2

	-- get first tile to draw, and on-screen offset, horizontally
	local firstTileX = 1 + math.floor(viewPortX1 / TILE_SIZE)
	local offsetX = viewPortX1 % TILE_SIZE
	
	-- get first tile to draw, and on-screen offset, vertically
	local firstTileY = 1 + math.floor(viewPortY1 / TILE_SIZE)
	local offsetY = viewPortY1 % TILE_SIZE
	
	local lastTileX = math.min(firstTileX + rectWidthTiles - 1, WORLD_WIDTH)
	local lastTileY = math.min(firstTileY + rectHeightTiles - 1, WORLD_HEIGHT)
	
	local firstFloorColor = TILE_COLOR_FLOOR_1

	local tileY = -offsetY
	for verTile = firstTileY, lastTileY do
		local floorColor = firstFloorColor
		local tileX = -offsetX
		for horTile = firstTileX, lastTileX do
			if ((horTile >= 1) and (verTile >= 1)) then
				local posIndex = (verTile - 1) * WORLD_WIDTH + horTile
				local wall = (state[1].tiles[posIndex] == 1)

				if (not wall) then
					drawFloor(floorColor,rect.x+tileX,rect.y+tileY)

					-- draw objects and creatures
					-- ...
				else
					drawWall(rect.x+tileX,rect.y+tileY)
				end
			end

			if (floorColor == TILE_COLOR_FLOOR_1) then
				floorColor = TILE_COLOR_FLOOR_2
			else
				floorColor = TILE_COLOR_FLOOR_1
			end

			tileX = tileX + TILE_SIZE	
		end

		if (firstFloorColor == TILE_COLOR_FLOOR_1) then
			firstFloorColor = TILE_COLOR_FLOOR_2
		else
			firstFloorColor = TILE_COLOR_FLOOR_1
		end

		tileY = tileY + TILE_SIZE
	end

	layout.disableClipping()
end

return world