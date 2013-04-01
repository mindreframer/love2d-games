function love.load()
	hamster = {
		img = love.graphics.newImage('hamster.png'),
		x = 400, y = 300
	}
end

function love.update(dt)
	if love.keyboard.isDown('up') then
		hamster.y = hamster.y - dt * 200
	elseif love.keyboard.isDown('down') then
		hamster.y = hamster.y + dt * 200
	end

	if love.keyboard.isDown('left') then
		hamster.x = hamster.x - dt * 200
	elseif love.keyboard.isDown('right') then
		hamster.x = hamster.x + dt * 200
	end

	if love.mouse.isDown('l') then
		local x,y = love.mouse.getPosition()
		local dx,dy = x - hamster.x, y-hamster.y
		local len = math.sqrt(dx * dx + dy * dy)
		if len > 0 then
			hamster.x = hamster.x + dx/len * dt * 200
			hamster.y = hamster.y + dy/len * dt * 200
		end
	end
end

function love.draw()
	love.graphics.draw(hamster.img, hamster.x, hamster.y, 0, 1,1, 64,64)
end
