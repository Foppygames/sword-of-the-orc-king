-- world is a module that manages and displays the current game world

local aspect = require("modules.aspect")
local Hero = require("modules.actors.hero")
local layout = require("modules.layout")
local tiles = require("modules.tiles")

local world = {}

local BACKGROUND_COLOR = {0,0,0}
local TILE_COLOR_FLOOR = {0.12,0.12,0.12}
local TILE_COLOR_WALL_FRONT = {0.2,0.2,0.2}
local TILE_COLOR_WALL_TOP = {0.3,0.3,0.3}
local TILE_WIDTH = 18
local TILE_HEIGHT = 28
local WALL_HEIGHT = TILE_HEIGHT / 2
local WORLD_WIDTH = 50
local WORLD_HEIGHT = 50
local WORLD_DEPTH = 10

--world.hero = nil

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
				if (actor.type == "hero") then
					-- create actor
					local hero = Hero.create("Conan",x,y,level)
					table.insert(state[level].actors,hero)

					-- test and use name component
					if (hero.name ~= nil) then
						print(hero.name.getName().."!")
					end

					-- delete stored actor
					state[level].layout[posIndex].actor = nil
				end
			end
		end
	end
end

function world.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
	rectWidthTiles = math.floor(rect.width / TILE_WIDTH) + 2
	rectHeightTiles = math.floor(rect.height / TILE_HEIGHT) + 2
end

function world.create(levels,startingLevel)		
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

	-- add hero
	if (addHero) then
		local x = 2
		local y = 2
		local posIndex = (y - 1) * WORLD_WIDTH + x

		state[level].layout[posIndex].actor = {
			type = "hero"
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
		-- leaving current level
		if ((cameraTileZ ~= nil) and (cameraTileZ ~= z)) then
			storeActors(cameraTileZ)
		end

		-- set new level
		cameraTileZ = z
		createActors(cameraTileZ)

		-- set camera position to hero coordinates
		-- ...
		-- temp:
		cameraTileX = 2
		cameraTileY = 2
	end
end

function world.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)
	
	local cameraX = cameraTileX * TILE_WIDTH - TILE_WIDTH / 2
	local cameraY = cameraTileY * TILE_HEIGHT - TILE_HEIGHT / 2

	local viewPortX1 = cameraX - rect.width / 2
	local viewPortY1 = cameraY - rect.height / 2

	-- get first tile to draw, and on-screen offset, horizontally
	local firstTileX = 1 + math.floor(viewPortX1 / TILE_WIDTH)
	local offsetX = viewPortX1 % TILE_WIDTH
	
	-- get first tile to draw, and on-screen offset, vertically
	local firstTileY = 1 + math.floor(viewPortY1 / TILE_HEIGHT)
	local offsetY = viewPortY1 % TILE_HEIGHT
	
	local lastTileX = math.min(firstTileX + rectWidthTiles - 1, WORLD_WIDTH)
	local lastTileY = math.min(firstTileY + rectHeightTiles - 1, WORLD_HEIGHT)
	
	local tileY = -offsetY
	for verTile = firstTileY, lastTileY do
		local tileX = -offsetX
		for horTile = firstTileX, lastTileX do
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
					drawWall(rect.x+tileX,rect.y+tileY,wallBelow)
				elseif (floor) then
					drawFloor(rect.x+tileX,rect.y+tileY)
				end
			end
			tileX = tileX + TILE_WIDTH
		end
		-- draw actors on row
		for i = 1, #state[cameraTileZ].actors do
			local actor = state[cameraTileZ].actors[i]
			if (actor.y == verTile) then
				local cX = rect.x - offsetX + (actor.x - firstTileX) * TILE_WIDTH + TILE_WIDTH / 2
				local cY = rect.y + tileY + TILE_HEIGHT / 2

				-- test and use appearance component
				if (actor.appearance ~= nil) then
					actor.appearance.draw(cX,cY)
				end
			end
		end
		tileY = tileY + TILE_HEIGHT
	end

	layout.disableClipping()
end

function world.load()
	-- ...
end

function world.save()
	-- ...
end

return world