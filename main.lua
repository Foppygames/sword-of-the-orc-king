local actionSystem = require("modules.ecs.systems.actionSystem")
local aspect = require("modules.aspect")
local entityManager = require("modules.ecs.managers.entitymanager")
local energySystem = require("modules.ecs.systems.energySystem")
local layout = require("modules.layout")
local log = require("modules.log")
local renderSystem = require("modules.ecs.systems.rendersystem")
local utils = require("modules.utils")
local world = require("modules.world")

local GAME_NAME = "Sword of the Orc King"
local LEVELS = 3
local STARTING_LEVEL = 1
local TURN_PAUSE_TIME = 0.1

local STATE_TITLE = 0
local STATE_PLAY = 1
local STATE_GAME_OVER = 2

local cameraPosition = {
	x = 1,
	y = 1,
	z = STARTING_LEVEL
}
local state
local turnPauseTime

function love.load()
	aspect.init()
	layout.init(aspect.getGameWidth(),aspect.getGameHeight())
	log.init(layout.DRAWING_AREA_LOG)
	world.init(layout.DRAWING_AREA_WORLD)
	
	love.window.setTitle(GAME_NAME)
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")

	switchToState(STATE_TITLE)
end

function switchToState(newState)
	state = newState
	
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",20))
	
	if (state == STATE_PLAY) then
		entityManager.reset()

		world.createNew(LEVELS,STARTING_LEVEL)
		updateCameraPosition()
		world.setCamera(cameraPosition.x,cameraPosition.y,cameraPosition.z)

		log.clear()
		log.addEntry("You enter the dungeon.",log.TEXT_COLOR_DEFAULT)
		log.addEntry("You see a bat.",log.TEXT_COLOR_DEFAULT)

		turnPauseTime = TURN_PAUSE_TIME
	end
end

function updateCameraPosition()
	local cameraEntityPosition = entityManager.getFirstCameraEntityPosition()
	if (cameraEntityPosition ~= nil) then
		cameraPosition.x = cameraEntityPosition.x
		cameraPosition.y = cameraEntityPosition.y
		cameraPosition.z = cameraEntityPosition.z
	end
end

function love.mousepressed(x,y,button,istouch,presses)
	if (state == STATE_TITLE) then
		if (button == 1) then
			switchToState(STATE_PLAY)
		end
	end
	if (state == STATE_PLAY) then
		-- ...
	end
	if (state == STATE_GAME_OVER) then
		if (button == 1) then
			switchToState(STATE_TITLE)
		end
	end
end

function love.draw()
	aspect.apply()
	
	if (state == STATE_TITLE) then
		love.graphics.setColor(0.470,0.902,1)
		love.graphics.printf(GAME_NAME,0,30,aspect.getGameWidth(),"center")	
		love.graphics.printf("W = windowed / full screen",0,120,aspect.getGameWidth(),"center")
		love.graphics.printf("Click to start",0,170,aspect.getGameWidth(),"center")
	end
	
	if (state == STATE_PLAY) then
		love.graphics.clear(0.2,0.2,0.2)

		log.draw()
		world.draw()
		renderSystem.update(world.getViewPortData())
		
		-- ...
	end
	
	if (state == STATE_GAME_OVER) then
		love.graphics.setColor(1,1,1)
		love.graphics.print("GAME OVER",130,60)
	end
	
	aspect.letterbox()
end

function love.update(dt)
	if (state == STATE_PLAY) then
		turnPauseTime = turnPauseTime - dt
		if (turnPauseTime <= 0) then
			energySystem.update()
			actionSystem.update()

			turnPauseTime = turnPauseTime + TURN_PAUSE_TIME
			-- note: turn pause time is a delay so we can see what is going on
			-- in a stage of development when no player input pause is present
			-- (player input will add a natural break in game time progress)

			updateCameraPosition()
			world.setCamera(cameraPosition.x,cameraPosition.y,cameraPosition.z)
		end
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
		end
		if (key == "escape") then
			love.event.quit()
		end
	end
	if (state == STATE_PLAY) then
		if (key == "escape") then
			-- save game state to continue play later
			-- ...

			switchToState(STATE_TITLE)
		end
	end
	if (state == STATE_GAME_OVER) then
		if (key == "space") then
			switchToState(STATE_TITLE)
		end
	end
end