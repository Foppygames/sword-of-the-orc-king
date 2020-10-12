-- stats is a module that displays information about the camera entity's stats in the stats area

local actionManager = require("modules.ecs.managers.actionmanager")
local colors = require("modules.colors")
local entityManager = require("modules.ecs.managers.entitymanager")
local layout = require("modules.layout")

local stats = {}

local BACKGROUND_COLOR = colors.get("DARK_GREY")
local TEXT_COLOR_LABEL = colors.get("LIGHT_GREY")
local TEXT_COLOR_VALUE = colors.get("WHITE")

local LINE_HEIGHT = 16
local PADDING_LEFT = 4

local entity
local rect

function stats.init(drawingAreaIndex)
	rect = layout.getRect(drawingAreaIndex)
end

local function displayHealth(line)
	local printTable = {
		TEXT_COLOR_LABEL, "Health: "
	}
	if entityManager.entityHas(entity,{"stats"}) and entity.stats.health ~= nil then
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,entity.stats.health.."/"..entity.stats.healthMax)
	else
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,"-")
	end
	love.graphics.setColor(colors.get("WHITE"))
	love.graphics.print(printTable,rect.x+PADDING_LEFT,rect.y+(line-1)*LINE_HEIGHT)
end

local function displayStrength(line)
	local printTable = {
		TEXT_COLOR_LABEL, "Strength: "
	}
	if entityManager.entityHas(entity,{"stats"}) and entity.stats.strength ~= nil then
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,entity.stats.strength)
	else
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,"-")
	end
	love.graphics.setColor(colors.get("WHITE"))
	love.graphics.print(printTable,rect.x+PADDING_LEFT,rect.y+(line-1)*LINE_HEIGHT)
end

local function displayAttack(line)
	local printTable = {
		TEXT_COLOR_LABEL, "Attack: "
	}
	if entityManager.entityHas(entity,{"stats"}) and entity.stats.attack ~= nil then
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,entity.stats.attack)
	else
		table.insert(printTable,TEXT_COLOR_VALUE)
		table.insert(printTable,"-")
	end
	love.graphics.setColor(colors.get("WHITE"))
	love.graphics.print(printTable,rect.x+PADDING_LEFT,rect.y+(line-1)*LINE_HEIGHT)
end

function stats.draw()
	layout.drawBackground(rect,BACKGROUND_COLOR)
	layout.enableClipping(rect)

	displayHealth(1)
	displayStrength(2)
	displayAttack(3)

	layout.disableClipping()
end

function stats.update(targetEntity)
	entity = targetEntity
end

return stats