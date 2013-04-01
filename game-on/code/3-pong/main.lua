HC = require 'hardoncollider'
vector = require 'hardoncollider.vector'

function on_collide(dt, a,b)
	local other
	if a == ball then
		other = b
	elseif b == ball then
		other = a
	else
		return
	end

	if other == goalLeft then
		ball.velocity = vector(200,0)
		ball:moveTo(400,300)
	elseif other == goalRight then
		ball.velocity = vector(-200,0)
		ball:moveTo(400,300)
	elseif other == borderTop or other == borderBottom then
		ball.velocity.y = -ball.velocity.y
	else
		local px,py = other:center()
		local bx,by = ball:center()
		ball.velocity.x = -ball.velocity.x
		ball.velocity.y = by - py

		ball.velocity = ball.velocity:normalized() * 200
	end
end

function love.load()
	HC.init(100, on_collide)

	ball = HC.addCircle(400,300, 10)
	paddleLeft = HC.addRectangle(10,250, 20,100)
	paddleRight = HC.addRectangle(770,250, 20,100)
	ball.velocity = vector(-200, 0)

	borderTop = HC.addRectangle(0, -100, 800,100)
	borderBottom = HC.addRectangle(0,600, 800,100)
	goalLeft = HC.addRectangle(-100,0, 100,600)
	goalRight = HC.addRectangle(800,0, 100,600)
end

function love.update(dt)
	dt = math.min(dt, 1/30)

	ball:move(ball.velocity.x * dt, ball.velocity.y * dt)

	if love.keyboard.isDown('w') then
		paddleLeft:move(0, -100 * dt)
	elseif love.keyboard.isDown('s') then
		paddleLeft:move(0, 100 * dt)
	end

	if love.keyboard.isDown('up') then
		paddleRight:move(0, -100 *dt)
	elseif love.keyboard.isDown('down') then
		paddleRight:move(0, 100 * dt)
	end

	HC.update(dt)
end

function love.draw()
	ball:draw('fill', 16)
	paddleLeft:draw('fill')
	paddleRight:draw('fill')
end
