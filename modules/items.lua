-- items is a module that displays information about the camera entity's items in the items area

local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local grammar = require("modules.grammar")
local layout = require("modules.layout")

local items = {}

items.STATE_DEFAULT = 0
items.STATE_INVENTORY = 1

local BACKGROUND_COLOR = colors.get("BLUE")
local TEXT_COLOR_DEFAULT = colors.get("LIGHT_BLUE")
local TEXT_COLOR_KEY = colors.get("YELLOW")
local TEXT_COLOR_ITEM = colors.get("WHITE")
local TEXT_COLOR_INVENTORY_COUNT = colors.get("WHITE")

local LINE_HEIGHT = 16
local PADDING_LEFT = 4

local GROUND_ITEM_LABEL = "On ground: "
local GROUND_ITEM_TEXT_NONE = "nothing"

local INVENTORY_COUNT_LABEL = "Inventory: "
local INVENTORY_COUNT_TEXT_NONE = "empty"

local entity
local groundItemName
local inventoryCount
local inventoryIndex
local rect
local state

function items.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
end

local function displayGroundItem()
	if (groundItemName == nil) then
		love.graphics.setColor(TEXT_COLOR_DEFAULT)
		love.graphics.print(GROUND_ITEM_LABEL..GROUND_ITEM_TEXT_NONE,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT)
	else
		local groundItemPrintTable = {
			TEXT_COLOR_DEFAULT, GROUND_ITEM_LABEL,
			TEXT_COLOR_ITEM, groundItemName,
			TEXT_COLOR_DEFAULT, " (",
			TEXT_COLOR_KEY, "g",
			TEXT_COLOR_DEFAULT, "et)"
		}
		love.graphics.setColor(colors.get("WHITE"))
		love.graphics.print(groundItemPrintTable,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT)
	end
end

local function displayInventory()
	-- display header
	local headerPrintTable = {
		TEXT_COLOR_DEFAULT, "Inventory (",
		TEXT_COLOR_KEY, "up",
		TEXT_COLOR_DEFAULT, "/",
		TEXT_COLOR_KEY, "down",
		TEXT_COLOR_DEFAULT, ", ",
		TEXT_COLOR_KEY, "esc",
		TEXT_COLOR_DEFAULT, " to exit)"
	}
	love.graphics.setColor(colors.get("WHITE"))
	love.graphics.print(headerPrintTable,rect.x+PADDING_LEFT,rect.y)
	
	if entityManager.entityHas(entity,{"inventory"}) then
		if (#entity.inventory.items > 0) then
			-- display items
			love.graphics.setColor(TEXT_COLOR_ITEM)
			for i = 1, #entity.inventory.items do
				-- current item is selected
				if (inventoryIndex == i) then
					love.graphics.setColor(TEXT_COLOR_DEFAULT)
					love.graphics.rectangle("fill",rect.x+PADDING_LEFT/2,rect.y+LINE_HEIGHT*i-1,rect.width-PADDING_LEFT,LINE_HEIGHT)
					love.graphics.setColor(TEXT_COLOR_ITEM)
				end
				local person, text = grammar.resolveEntity(entity.inventory.items[i],true)
				love.graphics.print(text,rect.x+PADDING_LEFT,rect.y+LINE_HEIGHT*i-1)
			end

			-- display available actions for selected item
			local actionsPrintTable = {
				TEXT_COLOR_DEFAULT, "(",
				TEXT_COLOR_KEY, "d",
				TEXT_COLOR_DEFAULT, "rop, ",
				TEXT_COLOR_KEY, "e",
				TEXT_COLOR_DEFAULT, "quip)"
			}
			love.graphics.setColor(colors.get("WHITE"))
			love.graphics.print(actionsPrintTable,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT)
		end
	end
end

local function displayInventoryCount()
	if (inventoryCount == 0) then
		love.graphics.setColor(TEXT_COLOR_DEFAULT)
		love.graphics.print(INVENTORY_COUNT_LABEL..INVENTORY_COUNT_TEXT_NONE,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT*2)
	else
		local itemWord
		if (inventoryCount ~= 1) then
			itemWord = "items"
		else
			itemWord = "item"
		end
		local inventoryCountPrintTable = {
			TEXT_COLOR_DEFAULT, INVENTORY_COUNT_LABEL,
			TEXT_COLOR_INVENTORY_COUNT, inventoryCount.." "..itemWord,
			TEXT_COLOR_DEFAULT, " (",
			TEXT_COLOR_KEY, "i",
			TEXT_COLOR_DEFAULT, "nventory)"
		}
		love.graphics.setColor(colors.get("WHITE"))
		love.graphics.print(inventoryCountPrintTable,rect.x+PADDING_LEFT,rect.y+rect.height-LINE_HEIGHT*2)
	end
end

function items.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)

	if (state == items.STATE_DEFAULT) then
		displayGroundItem()
		displayInventoryCount()
	elseif (state == items.STATE_INVENTORY) then
		displayInventory()
	end
	
	layout.disableClipping()
end

function items.reset()
	entity = nil
	groundItemName = nil
	inventoryCount = 0
	inventoryIndex = 1
	items.switchToState(items.STATE_DEFAULT)
end

-- returns action and new key listener to be used in input module 
function items.keyListenerInventory(key)
	local action = nil
	local listener = items.keyListenerInventory
	if (key == "escape") then
		listener = items.switchToState(items.STATE_DEFAULT)
	end
	if entityManager.entityHas(entity,{"inventory"}) then
		if ((key == "up") or (key == "kp8")) and (inventoryIndex > 1) then
			inventoryIndex = inventoryIndex - 1
		end
		if ((key == "down") or (key == "kp2")) and (inventoryIndex < #entity.inventory.items) then
			inventoryIndex = inventoryIndex + 1
		end
	end
	return action, listener
end

-- returns new key listener to be used in input module
function items.switchToState(newState)
	state = newState
	if (state == items.STATE_INVENTORY) then
		return items.keyListenerInventory
	else
		return nil
	end
end

function items.update(targetEntity)
	entity = targetEntity
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

		-- update inventory count
		if entityManager.entityHas(entity,{"inventory"}) then
			inventoryCount = #entity.inventory.items
		else
			inventoryCount = 0
		end
	else
		items.reset()
	end
end

return items