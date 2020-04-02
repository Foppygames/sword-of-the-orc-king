-- map is a module for creating dungeon layouts

local map = {}

-- Note: room dimensions do not include walls
local ROOM_GRID_WIDTH = 4
local ROOM_GRID_HEIGHT = 4
local ROOM_GRID_MARGIN = 1
local MIN_ROOM_WIDTH = 8
local MIN_ROOM_HEIGHT = 8
local MAX_ROOM_WIDTH = 20
local MAX_ROOM_HEIGHT = 20

local DIRECTIONS = {
	{
		dX = 0,
		dY = -1
	},
	{
		dX = 1,
		dY = 0
	},
	{
		dX = 0,
		dY = 1
	},
	{
		dX = -1,
		dY = 0
	}
}

-- connect each room to only its east and south neighbour to avoid double corridors
local CONNECTION_DIRECTION_INDEXES = {2,3}

-- number of rooms * (max room width + 2 walls) + margins between rooms
map.WORLD_WIDTH = ROOM_GRID_WIDTH * (MAX_ROOM_WIDTH + 2) + (ROOM_GRID_WIDTH - 1) * ROOM_GRID_MARGIN
map.WORLD_HEIGHT = ROOM_GRID_HEIGHT * (MAX_ROOM_HEIGHT + 2) + (ROOM_GRID_HEIGHT - 1) * ROOM_GRID_MARGIN

-- returns location and dimensions of rooms
local function createRooms()
	local rooms = {}
	for gridY = 1, ROOM_GRID_HEIGHT do
		rooms[gridY] = {}
		for gridX = 1, ROOM_GRID_WIDTH do
			local width = math.random(MIN_ROOM_WIDTH,MAX_ROOM_WIDTH)
			local height = math.random(MIN_ROOM_HEIGHT,MAX_ROOM_HEIGHT)
			local x1 = (gridX - 1) * (MAX_ROOM_WIDTH + 2 + ROOM_GRID_MARGIN) + math.random(2, 2 + MAX_ROOM_WIDTH - width)
			local y1 = (gridY - 1) * (MAX_ROOM_HEIGHT + 2 + ROOM_GRID_MARGIN) + math.random(2, 2 + MAX_ROOM_HEIGHT - height)

			rooms[gridY][gridX] = {
				x1 = x1,
				y1 = y1,
				width = width,
				height = height
			}
		end
	end
	return rooms
end

-- returns definitions of corridors connecting all rooms
local function createConnections(rooms)
	local connections = {}
	for gridY = 1, ROOM_GRID_HEIGHT do
		connections[gridY] = {}
		for gridX = 1, ROOM_GRID_WIDTH do
			connections[gridY][gridX] = {}

			for i = 1, #CONNECTION_DIRECTION_INDEXES do
				local dir = DIRECTIONS[CONNECTION_DIRECTION_INDEXES[i]]
				local targetGridX = gridX + dir.dX
				local targetGridY = gridY + dir.dY

				if (targetGridX >= 1) and (targetGridX <= ROOM_GRID_WIDTH) then
					if (targetGridY >= 1) and (targetGridY <= ROOM_GRID_HEIGHT) then
						local source = {
							x = nil,
							y = nil
						}
						local dest = {
							x = nil,
							y = nil
						}
						local bend = nil

						-- vertical
						if (dir.dX == 0) then
							source.x = math.random(rooms[gridY][gridX].x1, rooms[gridY][gridX].x1 + rooms[gridY][gridX].width - 1)
							dest.x = math.random(rooms[targetGridY][targetGridX].x1, rooms[targetGridY][targetGridX].x1 + rooms[targetGridY][targetGridX].width - 1)

							-- up
							if (dir.dY == -1) then
								source.y = rooms[gridY][gridX].y1 - 1
								dest.y = rooms[targetGridY][targetGridX].y1 + rooms[targetGridY][targetGridX].height
							-- down
							else
								source.y = rooms[gridY][gridX].y1 + rooms[gridY][gridX].height
								dest.y = rooms[targetGridY][targetGridX].y1 - 1
							end

							-- bend needed
							if (source.x ~= dest.x) then
								-- bend is understood to be defined as its vertical location along corridor
								bend = math.random(source.y + dir.dY, dest.y - dir.dY)
							end
						-- horizontal
						else
							source.y = math.random(rooms[gridY][gridX].y1, rooms[gridY][gridX].y1 + rooms[gridY][gridX].height - 1)
							dest.y = math.random(rooms[targetGridY][targetGridX].y1, rooms[targetGridY][targetGridX].y1 + rooms[targetGridY][targetGridX].height - 1)

							-- left
							if (dir.dX == -1) then
								source.x = rooms[gridY][gridX].x1 - 1
								dest.x = rooms[targetGridY][targetGridX].x1 + rooms[targetGridY][targetGridX].width
							-- right
							else
								source.x = rooms[gridY][gridX].x1 + rooms[gridY][gridX].width
								dest.x = rooms[targetGridY][targetGridX].x1 - 1
							end

							-- bend needed
							if (source.y ~= dest.y) then
								-- bend is understood to be defined as its horizontal location along corridor
								bend = math.random(source.x + dir.dX, dest.x - dir.dX)
							end
						end

						table.insert(connections[gridY][gridX],{
							source = source,
							dest = dest,
							bend = bend,
							dirIndex = CONNECTION_DIRECTION_INDEXES[i]
						})
					end
				end
			end
		end
	end
	return connections
end

-- returns tile layout containing only empty values
local function createEmptyLayout()
	local layout = {}
	for x = 1, map.WORLD_WIDTH do
		for y = 1, map.WORLD_HEIGHT do
			local posIndex = (y - 1) * map.WORLD_WIDTH + x
			layout[posIndex] = {
				wall = 0,
				floor = 0,
				tile = nil,
				actor = nil
			}
		end
	end
	return layout
end

-- returns tile layout of dungeon level
function map.createLayout(level)
	local rooms = createRooms()
	local connections = createConnections(rooms)
	local layout = createEmptyLayout()

	local heroX = nil
	local heroY = nil

	-- add rooms
	for gridX = 1, ROOM_GRID_WIDTH do
		for gridY = 1, ROOM_GRID_HEIGHT do
			local room = rooms[gridY][gridX]

			-- hero starts in center of upper left corner room
			if (gridX == 1) and (gridY == 1) and (heroX == nil) then
				heroX = room.x1 + math.floor(room.width / 2)
				heroY = room.y1 + math.floor(room.height / 2)
			end

			for x = room.x1, room.x1 + room.width - 1 do
				for y = room.y1, room.y1 + room.height - 1 do
					local posIndex = (y - 1) * map.WORLD_WIDTH + x				
					layout[posIndex].floor = 1
					layout[posIndex].tile = "floor"
				end
			end
		end
	end

	-- add corridors
	for gridX = 1, ROOM_GRID_WIDTH do
		for gridY = 1, ROOM_GRID_HEIGHT do
			local roomConnections = connections[gridY][gridX]

			for i = 1, #roomConnections do
				local connection = roomConnections[i]
				local dX = DIRECTIONS[connection.dirIndex].dX
				local dY = DIRECTIONS[connection.dirIndex].dY
				local x = connection.source.x
				local y = connection.source.y
				local posIndex = (y - 1) * map.WORLD_WIDTH + x				
				layout[posIndex].floor = 1
				layout[posIndex].tile = "floor"
				repeat
					-- corridor is straight
					if (connection.bend == nil) then
						x = x + dX
						y = y + dY
					-- corridor has bend
					else
						-- corridor is vertical
						if (dX == 0) then
							-- currently in bend
							if (y == connection.bend) then
								-- end of bend reached
								if (x == connection.dest.x) then
									y = y + dY
								-- end of bend not reached
								else
									if (x < connection.dest.x) then
										x = x + 1
									else
										x = x - 1
									end
								end
							-- not currently in bend
							else
								x = x + dX
								y = y + dY
							end
						-- corridor is horizontal
						else
							-- currently in bend
							if (x == connection.bend) then
								-- end of bend reached
								if (y == connection.dest.y) then
									x = x + dX
								-- end of bend not reached
								else
									if (y < connection.dest.y) then
										y = y + 1
									else
										y = y - 1
									end
								end
							-- not currently in bend
							else
								x = x + dX
								y = y + dY
							end
						end
					end

					posIndex = (y - 1) * map.WORLD_WIDTH + x				
					layout[posIndex].floor = 1
					layout[posIndex].tile = "floor"
				until (x == connection.dest.x) and (y == connection.dest.y)

			end
		end
	end
	
	local posIndex = (heroY - 1) * map.WORLD_WIDTH + heroX

	layout[posIndex].actor = {
		type = "hero",
		data = {
			position = {
				x = heroX,
				y = heroY,
				z = level
			}
		}
	}

	return layout
end

return map