require 'AnAL'
Timer = require 'hump.timer'

local knoll_img = love.graphics.newImage('knoll_anim.png')
knolls = {}
function newKnoll()
	local x,y = math.random(100,700),math.random(100,500)
	local knoll = newAnimation(knoll_img, 77, 113, .1, 6)
	knoll:setMode('once')
	knolls[knoll] = {x,y}

	local delay = math.random(10,30) / 10
	Timer.add(delay, function() knoll.direction = -1; knoll:play() end)
	Timer.add(delay + .6, function() knolls[knoll] = nil end)
end

kapows = {}
function newKapow(text, x,y)
	local font = love.graphics.getFont()
	local pw,ph = font:getWidth(text), font:getHeight(text)
	local rot = (math.random() - .5) * math.pi/2
	local info = {
		text = text, rot = rot,
		x = x - (pw/2) * math.cos(rot),
		y = y - (ph/2) * math.sin(rot),
	}

	kapows[info] = info
	Timer.add(1, function() kapows[info] = nil end)
end

function love.load()
	love.graphics.setBackgroundColor(53,61,40)
	love.mouse.setVisible(false)
	math.randomseed(os.time())

	local hammer_img = love.graphics.newImage('hammer.png')
	hammer = newAnimation(hammer_img, 128, 256, 0)

	score = 0
	love.graphics.setFont(40)

	newKnoll()
	Timer.add(math.random(5,30)/10, function(f) newKnoll(); Timer.add(math.random(5,30)/10, f) end)
end

function love.update(dt)
	dt = math.min(dt, 1/30)
	for knoll,_ in pairs(knolls) do
		knoll:update(dt)
	end

	Timer.update(dt)
end

function love.draw()
	love.graphics.setColor(255,255,255)
	for knoll, pos in pairs(knolls) do
		knoll:draw(pos[1],pos[2], 0,1,1, 38,50)
	end

	local x,y = love.mouse.getPosition()
	hammer:draw(x,y, 0, 1,1, 64,86)

	for _,info in pairs(kapows) do
		love.graphics.print(info.text, info.x, info.y, info.rot)
	end

	love.graphics.setColor(255,255,255, 120)
	love.graphics.print('SCORE: ' .. score, 5,5)
end

function love.mousepressed(x,y,btn)
	hammer:seek(2)

	for knoll,pos in pairs(knolls) do
		local d = math.sqrt((x-pos[1])^2 + (y-pos[2])^2)
		if d < 70 then
			knolls[knoll] = nil
			newKapow('POW',x,y-20)
			score = score + 10
			return
		end
	end

	newKapow('OUCH',x,y-20)
	score = score - 5
end

function love.mousereleased(x,y,btn)
	hammer:seek(1)
end
