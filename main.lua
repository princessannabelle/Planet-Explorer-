-- Simple planet auto generator written in Love2D.
-- Coded in Lua by Annabelle Lee.
-- Main file for the game.

-- Load other classes I need.
camera = require('camera')

-- Show certain variables for ease of use.
debug = true

-- Default function.
-- Loads game assets.
function love.load(arg)
	-- We'll change the default background colour to something a bit more cute. (i.e. Not black.)
	love.graphics.setBackgroundColor(25, 25, 25)
	-- Custom font.
	font = love.graphics.newFont('assets/font/kvector.ttf', 14)
	love.graphics.setFont(font)
	-- Making the player entity. (Space ship.)
	player = {
		x = 344, -- X location.
		y = 300, -- Y location.
		v = 0,   -- Player velocity.
		img = nil, 	-- Will load later.
		w = nil, -- Width of image.
		h = nil  -- Height of image.
	}
	player.img = love.graphics.newImage('assets/entities/player_ship.png')
	player.w, player.h = player.img:getDimensions()
	-- End making player.
	-- Make background quad and image.
	bgImg  = love.graphics.newImage('assets/bg.png')
	-- Background quad coordinates.
	quadCoord = {
		x = 0,
		y = 0
	}
	bgQuad = love.graphics.newQuad(0, 0, 896 + bgImg:getWidth(), 600 + bgImg:getHeight(), bgImg:getDimensions())
	bgImg:setWrap('repeat', 'repeat')
	-- Set mouse cursor.
	Mouse = {
		pressed = 0,
		cursorNormalImage = love.graphics.newImage('assets/ui/normal_crosshair.png'),
		cursorAttackImage = love.graphics.newImage('assets/ui/enemy_crosshair.png')
	}
	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)
	-- Init camera.
	cam = camera(player.x, player.y)
	-- Load UI stuff.
	UICounters = {
		maxbullet = 10,
		maxboost  = 10,
		maxhp     = 10,
		maxshield =  5,
		currentbullet = 10,
		currentboost  = 10,
		boostconsumed = false,
		bulletsconsumed = false,
		currenthp     = 10,
		currentshield = 0,
		bulletcountimg = love.graphics.newImage('assets/ui/bulletcount.png'),
		boostcountimg  = love.graphics.newImage('assets/ui/boostcount.png'),
		hpcountimg     = love.graphics.newImage('assets/ui/hpcount.png'),
		shieldcountimg = love.graphics.newImage('assets/ui/shieldcount.png')
	}
	Powerups = {
		shieldpowerupimg = love.graphics.newImage('assets/ui/shieldPowerUp.png')
	}
end

-- Default function.
-- Update info for frame.
function love.update(dt)
	-- Lets get the location of the mouse. (Angle compared to the location of our player.)
	mouse_angle = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
	-- Mouse pressed? Set image as needed.
	if love.mouse.isDown(1) and UICounters.currentbullet > 0 and UICounters.bulletsconsumed == false then
		Mouse.pressed = 1
		if UICounters.currentbullet > 0 then
			UICounters.currentbullet = UICounters.currentbullet - 1
		end
	else
		if UICounters.currentbullet <= 0 then
			UICounters.bulletsconsumed = true
		end
		if UICounters.currentbullet < UICounters.maxbullet then
			UICounters.currentbullet = UICounters.currentbullet + dt * 4
		else
			UICounters.bulletsconsumed = false
		end
		Mouse.pressed = 0
	end
	-- Move the ship in the direction we're facing. Using acceleration and stuff.
	-- Acceleration. (Boost.) 
	if love.keyboard.isDown('space') and player.v < 3000 and UICounters.currentboost > 0 and UICounters.boostconsumed == false then
	    player.v = player.v + 200
	    if player.v > 3000 then
	        player.v = 3000
	    end
	    UICounters.currentboost = UICounters.currentboost - 1
	else
	    if player.v > 1000 then
	        player.v = player.v - 10
	    end
	    if UICounters.currentboost <= 0 then 
	    	UICounters.boostconsumed = true
	    end
	    if UICounters.currentboost < UICounters.maxboost then
	        UICounters.currentboost = UICounters.currentboost + dt
	    else
	    	UICounters.boostconsumed = false
	    end
	end
	-- Normal move.
	if love.keyboard.isDown('w') then
		if player.v < 1000 then
			player.v = player.v + 100
			if player.v > 1000 then
				player.v = 1000
			end
		end
		quadCoord.x = (quadCoord.x - math.cos(mouse_angle) * player.v * dt) % bgImg:getWidth()
		quadCoord.y = (quadCoord.y - math.sin(mouse_angle) * player.v * dt) % bgImg:getHeight()
	else
		if player.v > 0 then
			player.v = player.v - 10
		end
		quadCoord.x = (quadCoord.x - math.cos(mouse_angle) * player.v * dt) % bgImg:getWidth()
		quadCoord.y = (quadCoord.y - math.sin(mouse_angle) * player.v * dt) % bgImg:getHeight()
	end
	cam:lockPosition(player.x, player.y)
end

-- Default function.
-- Draw frame.
function love.draw(dt)
	-- Draw background.
	love.graphics.draw(bgImg, bgQuad, quadCoord.x - bgImg:getWidth(), quadCoord.y - bgImg:getHeight())
	-- Camera starts.
	cam:attach()
	-- Draw player.
	love.graphics.draw(player.img, player.x, player.y, mouse_angle, 1, 1, player.w / 2, player.h / 2)
	-- Camera ends. Draw any overlayed/UI stuff past this point.
	cam:detach()
	-- Draw Cursor.
	if Mouse.pressed == 1 then
		love.graphics.draw(Mouse.cursorAttackImage, love.mouse.getX() - Mouse.cursorAttackImage:getWidth() / 2, love.mouse.getY() - Mouse.cursorAttackImage:getHeight() / 2)
	else
		love.graphics.draw(Mouse.cursorNormalImage, love.mouse.getX() - Mouse.cursorNormalImage:getWidth() / 2, love.mouse.getY() - Mouse.cursorNormalImage:getHeight() / 2)
	end
	-- Draw the ammo remaining. + Text. 
	love.graphics.print("Ammo", 30, 570 - UICounters.bulletcountimg:getHeight() / 2 - 20)
	for bullet=1,UICounters.currentbullet do
		love.graphics.draw(UICounters.bulletcountimg, (18 * bullet) + (UICounters.bulletcountimg:getWidth() / 2), 570 - UICounters.bulletcountimg:getHeight() / 2)
	end
	-- Draw boost power remaining.
	-- Needs a clever way of drawing it in backwards order. (Right to left.) + Text. 
	if UICounters.currentboost > 0 then
		love.graphics.print("Boost", 896 - 74 - UICounters.boostcountimg:getWidth() / 2, 570 - UICounters.boostcountimg:getHeight() / 2 - 20)
	end
	for boost=1,UICounters.currentboost do
		love.graphics.draw(UICounters.boostcountimg, 896 - 18 - (18 * boost) - UICounters.boostcountimg:getWidth() / 2, 570 - UICounters.boostcountimg:getHeight() / 2)
	end
	-- Draw in remaining hp.
	love.graphics.print("Health", 30, 9)	
	for hp=1,UICounters.currenthp do
		love.graphics.draw(UICounters.hpcountimg, (18 * hp) + (UICounters.hpcountimg:getWidth() / 2), 40 - UICounters.hpcountimg:getHeight() / 2)
	end
	-- Draw in remaining shields.
	if UICounters.currentshield > 0 then
		love.graphics.print("Shields", 30, 9 + UICounters.hpcountimg:getHeight() + 25)
	end
	for shield=1,UICounters.currentshield do
		love.graphics.draw(UICounters.shieldcountimg, (18 * shield) + (UICounters.shieldcountimg:getWidth() / 2), 9 + UICounters.hpcountimg:getHeight() + 25 + UICounters.hpcountimg:getHeight() / 2 + 5)
	end
	if debug == true then
		love.graphics.print("Speed", 896 - 75 - UICounters.boostcountimg:getWidth() / 2, 9)
		love.graphics.print(tostring(player.v), 896 - 75 - UICounters.boostcountimg:getWidth() / 2, 22)
	end
end