-- map is a module for creating dungeon layouts

local map = {}

function map.createLayout(width,height,level)
	local layout = {}

	-- create one room as large as the level for testing
	for y = 1, width do
		for x = 1, height do
			local wall = 0
			local floor = 0
			local tile = nil

			if (((x == 1 ) or (x == width)) and (y <= height)) then
				wall = 1
			end
			if (((y == 1) or (y == height)) and (x <= width)) then
				wall = 1
			end
			if ((x > width*0.25) and (x < width*0.75)) then
				if ((y > height*0.25) and (y < height*0.75)) then
					wall = 1
				end
			end
			if ((x > 1 ) and (x < width) and (y > 1 ) and (y < height)) then
				floor = 1
			end

			if (wall == 1) then
				tile = "wall"
			elseif (floor == 1) then
				tile = "floor"
			end

			table.insert(layout,{
				wall = wall,
				floor = floor,
				actor = nil,
				tile = tile
			})
		end
	end

	-- add stored entities to layout for testing
	if (level == 1) then
		local x = 3
		local y = 3
		local posIndex = (y - 1) * width + x

		layout[posIndex].actor = {
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
		posIndex = (y - 1) * width + x

		layout[posIndex].actor = {
			type = "bat",
			data = {
				position = {
					x = x,
					y = y,
					z = level
				}
			}
		}

		x = 10
		y = 3
		posIndex = (y - 1) * width + x

		layout[posIndex].actor = {
			type = "orc",
			data = {
				position = {
					x = x,
					y = y,
					z = level
				}
			}
		}
	end

	return layout
end

return map