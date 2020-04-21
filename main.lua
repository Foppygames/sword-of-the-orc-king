local actionSystem = require("modules.ecs.systems.actionSystem")
local aspect = require("modules.aspect")
local colors = require("modules.colors")
local energySystem = require("modules.ecs.systems.energySystem")
local entityManager = require("modules.ecs.managers.entitymanager")
local images = require("modules.images")
local input = require("modules.input")
local items = require("modules.items")
local layout = require("modules.layout")
local log = require("modules.log")
local renderSystem = require("modules.ecs.systems.rendersystem")
local tiles = require("modules.tiles")
local utils = require("modules.utils")
local visionSystem = require("modules.ecs.systems.visionsystem")
local world = require("modules.world")

local GAME_NAME = "Sword of the Orc King"

local STATE_TITLE = 0
local STATE_PLAY = 1
local STATE_GAME_OVER = 2

local state

function love.load()
	math.randomseed(os.time())
	
	aspect.init()
	colors.init()
	images.init()
	layout.init(aspect.getGameWidth(),aspect.getGameHeight())
	log.init(layout.DRAWING_AREA_LOG)
	items.init(layout.DRAWING_AREA_ITEMS)
	tiles.init()
	world.init(layout.DRAWING_AREA_WORLD)
	
	love.window.setTitle(GAME_NAME)
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",10))

	switchToState(STATE_TITLE)
end

function switchToState(newState)
	state = newState
	
	if (state == STATE_PLAY) then
		actionSystem.reset()
		entityManager.reset()
		input.resetAction()
		input.resetListener()
		items.reset()

		world.createNew()
		world.createEntities(nil)

		log.clear()
		log.addEntry("You enter the dungeon.")
	end
end

function love.mousepressed(x,y,button,istouch,presses)
	if (state == STATE_TITLE) then
		if (button == 1) then
			switchToState(STATE_PLAY)
			return
		end
	end
	if (state == STATE_PLAY) then
		-- ...
	end
	if (state == STATE_GAME_OVER) then
		if (button == 1) then
			switchToState(STATE_TITLE)
			return
		end
	end
end

function love.draw()
	aspect.apply()
	
	if (state == STATE_TITLE) then
		love.graphics.setColor(1,1,1)
		love.graphics.printf(GAME_NAME,0,30,aspect.getGameWidth(),"center")	
		love.graphics.printf("W = windowed / full screen",0,120,aspect.getGameWidth(),"center")
		love.graphics.printf("Click to start",0,170,aspect.getGameWidth(),"center")
	end
	
	if (state == STATE_PLAY) then
		love.graphics.clear(colors.get("LIGHT_BLUE"))

		log.draw()
		items.draw()
		world.draw()
	end
	
	if (state == STATE_GAME_OVER) then
		love.graphics.setColor(1,1,1)
		love.graphics.print("GAME OVER",130,60)
	end
	
	aspect.letterbox()
end

function love.update(dt)
	if (state == STATE_PLAY) then
		local allUpdated = actionSystem.update(input.getAction())

		input.resetAction()

		if (allUpdated) then
			energySystem.update()
		end

		local cameraEntity = visionSystem.update()
		
		items.update(cameraEntity)
		world.updateViewport(cameraEntity)
	end
end

function love.keypressed(key)
	if (state == STATE_TITLE) then
		if (key == "w") then
			aspect.toggleFullScreen()
		end
		if (key == "space") then
			-- load saved game state if available
			-- ...
			switchToState(STATE_PLAY)
			return
		end
		if (key == "escape") then
			love.event.quit()
		end
	end
	if (state == STATE_PLAY) then
		if (key == "f1") then
			-- save game state to continue play later
			-- ...
			switchToState(STATE_TITLE)
			return
		else
			input.registerKeyPressed(key)
		end
	end
	if (state == STATE_GAME_OVER) then
		if (key == "space") then
			switchToState(STATE_TITLE)
			return
		end
	end
end