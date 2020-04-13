-- status is a module that displays information about the camera entity in the status area

local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local layout = require("modules.layout")

local status = {}

local BACKGROUND_COLOR = colors.get("BLUE")
local TEXT_COLOR_DEFAULT = colors.get("LIGHT_BLUE")
local TEXT_COLOR_KEY = colors.get("YELLOW")
local TEXT_COLOR_GROUND_ITEM = colors.get("WHITE")

local LINE_HEIGHT = 16
local PADDING_LEFT = 4

local GROUND_ITEM_LABEL = "Ground: "
local GROUND_ITEM_TEXT_NONE = "nothing"
local GROUND_ITEM_LABEL_WIDTH = love.graphics.getFont():getWidth(GROUND_ITEM_LABEL)

local groundItemName
local rect

function status.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
end

local function displayGroundItem()
	if (groundItemName == nil) then
		love.graphics.setColor(TEXT_COLOR_DEFAULT)
		love.graphics.print(GROUND_ITEM_LABEL..GROUND_ITEM_TEXT_NONE,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT)
	else
		local groundItemPrintTable = {
			TEXT_COLOR_DEFAULT, GROUND_ITEM_LABEL,
			TEXT_COLOR_GROUND_ITEM, groundItemName,
			TEXT_COLOR_DEFAULT, " (",
			TEXT_COLOR_KEY, "g",
			TEXT_COLOR_DEFAULT, "et)"
		}
		love.graphics.setColor(colors.get("WHITE"))
		love.graphics.print(groundItemPrintTable,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT)
	end
end

function status.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)
	displayGroundItem()
	layout.disableClipping()
end

function status.reset()
	groundItemName = nil
end

function status.update(entity)
	if (entity ~= nil) then
		-- update ground item name
		local groundItem = entityManager.getEntityAtLocationHaving(entity.position.x,entity.position.y,entity.position.z,{"item"})
		if (groundItem == nil) then
			groundItemName = nil
		else
			if entityManager.entityHas(groundItem,{"name"}) then
				if (groundItem.name.specificName ~= nil) then
					groundItemName = groundItem.name.specificName
				else
					groundItemName = groundItem.name.genericName
				end
			else
				groundItemName = "unnamed item"
			end
		end
	else
		status.reset()
	end
end

return status