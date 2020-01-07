local aspect = require("modules.aspect")
local layout = require("modules.layout")
local log = require("modules.log")
local utils = require("modules.utils")
local world = require("modules.world")

local GAME_NAME = "Adventure Game"
local LEVELS = 3
local STARTING_LEVEL = 1

local STATE_TITLE = 0
local STATE_PLAY = 1
local STATE_GAME_OVER = 2

local state

function love.load()
	-- initialize modules for program session
	aspect.init()
	layout.init(aspect.getGameWidth(),aspect.getGameHeight())
	log.init(layout.DRAWING_AREA_LOG)
	world.init(layout.DRAWING_AREA_WORLD)
	
	-- initialize global settings for program session
	setupGame()

	switchToState(STATE_TITLE)
end

function setupGame()
	love.window.setTitle(GAME_NAME)
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
end

function switchToState(newState)
	state = newState
	
	love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",20))
	
	if (state == STATE_TITLE) then
		-- ...
	elseif (state == STATE_PLAY) then
		world.create(LEVELS,STARTING_LEVEL)
		world.setCamera(nil,nil,STARTING_LEVEL)

		log.clear()
		log.addEntry("You enter the dungeon.",log.TEXT_COLOR_DEFAULT)
	elseif (state == STATE_GAME_OVER) then
		-- ...
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
		for i = 2, 5 do
			local color = 1-(5-i)*0.2
			love.graphics.setColor(color,color,color)
			love.graphics.printf(GAME_NAME,0,30+i*1,aspect.getGameWidth(),"center")	
		end
		
		love.graphics.setColor(0.470,0.902,1)
		love.graphics.printf("W = windowed / full screen",0,120,aspect.getGameWidth(),"center")
		
		love.graphics.setColor(1,1,1)
		love.graphics.printf("Click to start",0,170,aspect.getGameWidth(),"center")
	end
	
	if (state == STATE_PLAY) then
		log.draw()
		world.draw()

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
		-- ...
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