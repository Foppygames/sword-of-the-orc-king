-- images is a module that manages the set of available entity graphics

local images = {}

images.items = {
	bat = {
		path = "images/entities/bat.png"
	},
	human = {
		path = "images/entities/human.png"
	},
	orc = {
		path = "images/entities/orc_green.png"
	}
}

function images.init()
	for id,data in pairs(images.items) do
		images.items[id].image = nil
	end
end

function images.get(id)
	if (images.items[id].image == nil) then
		images.items[id].image = love.graphics.newImage(images.items[id].path)
	end
	return images.items[id].image
end

return images