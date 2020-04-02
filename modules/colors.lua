-- colors is a module providing color palette constants based on the vice c64 palette

local colors = {}

local palette = {
	BLACK = {0,0,0},
	WHITE = {255,255,255},
	RED = {137,64,54},
	CYAN = {122,191,199},
	PURPLE = {138,70,174},
	GREEN = {104,169,65},
	BLUE = {62,49,162},
	YELLOW = {208,220,113},
	ORANGE = {144,95,37},
	BROWN = {92,71,0},
	PINK = {187,119,109},
	DARK_GREY = {85,85,85},
	GREY = {128,128,128},
	LIGHT_GREEN = {172,234,136},
	LIGHT_BLUE = {124,112,218},
	LIGHT_GREY = {171,171,171}
}

function colors.init()
	for label,color in pairs(palette) do
		for i = 1,3 do
			palette[label][i] = palette[label][i] / 255
		end
	end
end

function colors.get(color)
	return palette[color]
end

return colors