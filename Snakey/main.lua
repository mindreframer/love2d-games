--[[
	Snakey by Dale James
	Bullshit game that no one will ever play.
]]

--load
function love.load()
	--loading stuff
	love.graphics.setCaption("Snakey")
	
	--snake
	snake = {}
	snake.pos = {10, 7}
	snake.bits = {}
	table.insert(snake.bits, snake.pos)
	snake.direction = ""
	snake.size = 1
	
	--background
	background = {}
	background.under = love.graphics.newImage("gfx/bg.png")
	background.over = love.graphics.newImage("gfx/bgFade.png")
	background.display = love.graphics.newImage("gfx/bgDisplay.png")
	background.alpha = 0
	background.fade = 25
	
	--pil item
	pil = {}
	repeat
		pil.pos = {math.random(0, 19), math.random(0, 14)}
	until pil.pos[1] ~= 10 and pil.pos[2] ~= 7
	pil.sound = love.audio.newSource("sfx/spawn.ogg", "static")
	
	--game stuff
	--save the highscore to the file
	saveFile = love.filesystem.newFile("high.score")
	if highscore then
		saveFile:open("w")
		saveFile:write(highscore)
		saveFile:close()
	end
		
	--load the highscore file
	if love.filesystem.exists("high.score") then
		saveFile:open("r")
		highscore = saveFile:read()
		saveFile:close()
	end
	
	highscore = highscore or 0
	score = 0
	speed = 0.30
	count = 0
	
	isEmpty = function(pos)
		for k, v in ipairs(snake.bits) do
			if pos[1] == v[1] and pos[2] == v[2] then return nil end
		end
		return true
	end
end

--update
function love.update(dt)
	--update background
	background.alpha = background.alpha + background.fade * dt
	if background.alpha >= 150 then 
		background.alpha = 150
		background.fade = -25
	elseif background.alpha <= 0 then
		background.alpha = 0
		background.fade = 25
	end
	
	--movement speed timer
	count = count + 1 * dt
	
	--move the snake if the timer is high enough
	if count > speed then
		count = 0
		enableControl = true		
		--control the snake
		if snake.direction == "up" then
			snake.pos[2] = snake.pos[2] - 1 < 0 and 14 or snake.pos[2] - 1
		elseif snake.direction == "down" then
			snake.pos[2] = snake.pos[2] + 1 >= 15 and 0 or snake.pos[2] + 1
		elseif snake.direction == "left" then
			snake.pos[1] = snake.pos[1] - 1 < 0 and 19 or snake.pos[1] - 1
		elseif snake.direction == "right" then
			snake.pos[1] = snake.pos[1] + 1 >= 20 and 0 or snake.pos[1] + 1
		end
		table.insert(snake.bits, {snake.pos[1], snake.pos[2]})
		--check if the snake has found a pil
		if pil.pos[1] == snake.pos[1] and pil.pos[2] == snake.pos[2] then
			repeat
				pil.pos = {math.random(0, 19), math.random(0, 14)} --new pil. keep generating positions until we find one that is not occupied by the snake
			until isEmpty(pil.pos)
			pil.sound:stop()
			pil.sound:play()
			score = score + 1 * # snake.bits --yay
			speed = speed - 0.005 < 0.08 and 0.08 or speed - 0.005 --incrase well, the entire game
		else
			table.remove(snake.bits, 1)
		end
		--is the snake dead?
		for k, v in ipairs(snake.bits) do
			if k ~= # snake.bits then
				if v[1] == snake.pos[1] and v[2] == snake.pos[2] then love.load() end -- :(
			end
		end
		--check highscore
		highscore = math.max(score, highscore)
	end
end

--draw
function love.draw()
	love.graphics.push()
		love.graphics.translate(0, 15)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(background.under, 0, 0)
		love.graphics.setColor(255, 255, 255, background.alpha)
		love.graphics.draw(background.over, 0, 0)
		love.graphics.setColor(100 + background.alpha * 0.5, 200, 125 + background.alpha * -0.5, 255)
		love.graphics.rectangle("fill", pil.pos[1] * 16, pil.pos[2] * 16, 16, 16)
		for k, v in ipairs(snake.bits) do
			local color = (# snake.bits - k + 1) * 3
			love.graphics.setColor(200 - color, 255 - color, 255, 200)
			love.graphics.rectangle("fill", v[1] * 16, v[2] * 16, 16, 16)
		end
	love.graphics.pop()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(background.display, 0, 0)
	if snake.direction == "" then
		love.graphics.setColor(0, 0 ,0, 255)
		love.graphics.print("Press WASD or Arrow keys to start!", 1, 1)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("Press WASD or Arrow keys to start!", 0, 0)
	else
		love.graphics.setColor(0, 0 ,0, 255)
		love.graphics.print("Score: " .. score, 1, 1)
		love.graphics.print("Highscore: " .. highscore, 160, 1)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("Score: " .. score, 1, 1)
		love.graphics.print("Highscore: " .. highscore, 160, 1)
	end
end

--get controls
function love.keypressed(key)
	if enableControl then
		enableControl = nil
		if (key == "up" or key == "w") and snake.direction ~= "down" then
			snake.direction = "up"
		elseif (key == "down" or key == "s") and snake.direction ~= "up" then
			snake.direction = "down"
		elseif (key == "left" or key == "a") and snake.direction ~= "right" then
			snake.direction = "left"
		elseif (key == "right" or key == "d") and snake.direction ~= "left" then
			snake.direction = "right"
		elseif key == "escape" then
			love.event.push("quit") --goodbye
		end
	end
end