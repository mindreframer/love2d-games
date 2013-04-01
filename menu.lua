local lg = love.graphics

Menu = {}
Menu.__index = Menu

function Menu.create(names, functions, escape_function)
	local self = {}
	setmetatable(self, Menu)

	self.names = names
	self.functions = functions
	self.length = #names
	self.escape_function = escape_function

	self.width = 0
	for i,v in ipairs(names) do
		local w = fontBold:getWidth("* "..v.." *")
		self.width = math.max(self.width, w)
	end

	self.height = 16*self.length-9

	self.selected = 1

	return self
end

function Menu:keypressed(k,uni)
	if k == "down" then
		self.selected = self.selected + 1
		love.audio.play(snd.Blip)
		if self.selected > self.length then
			self.selected = 1
		end
	elseif k == "up" then
		self.selected = self.selected - 1
		love.audio.play(snd.Blip)
		if self.selected == 0 then
			self.selected = self.length
		end
	elseif k == "return" then
		love.audio.play(snd.Blip)
		if self.functions[self.selected] then
			self.functions[self.selected](self)
		end
	elseif k == "escape" then
		love.audio.play(snd.Blip)
		self.escape_function(self)
	end
end

function Menu:draw()
	local top = (HEIGHT-self.height)/2

	lg.setColor(0,0,0,200)
	lg.rectangle("fill",(WIDTH-self.width)/2-6, top-6, self.width+12, self.height+12)
	lg.setColor(255,255,255,255)

	lg.setFont(fontBold)
	for i=1,self.length do
		if i == self.selected then
			lg.printf("* "..self.names[i].." *", 0, top+(i-1)*16, WIDTH, "center")
		else
			lg.printf(self.names[i], 0, top+(i-1)*16, WIDTH, "center")
		end
	end
end

function createMenus()
	-- INGAME MENU
	ingame_menu = Menu.create(
		{"CONTINUE", "RESTART LEVEL", "OPTIONS", "EXIT LEVEL", "QUIT GAME"},
		{function() gamestate = STATE_INGAME end,
		 function() reloadMap() gamestate = STATE_INGAME end,
		 function() current_menu = options_menu end,
		 function() gamestate = STATE_LEVEL_MENU end,
		 function() love.event.quit() end},

		 function() gamestate = STATE_INGAME end
	)

	-- OPTIONS MENU
	options_menu = Menu.create(
		{"SCALE: X", "CAMERA SPEED: |=======|",
		"MUSIC VOLUME: |==========|", "SOUND VOLUME: |==========|", "BACK"},
		{nil,nil,nil,nil,
		function() if gamestate == STATE_INGAME_MENU then current_menu = ingame_menu
			else current_menu = main_menu end end},

		function() if gamestate == STATE_INGAME_MENU then current_menu = ingame_menu
			else current_menu = main_menu end end
	)

	function options_menu:update()
		self.names = {
			"SCALE: "..SCALE,
			"CAMERA SPEED: |"..string.rep("=",SCROLL_SPEED-2)..string.rep("-",9-SCROLL_SPEED).."|",
			"MUSIC VOLUME: |"..string.rep("=",music_volume*10)..string.rep("-",10-music_volume*10).."|",
			"SOUND VOLUME: |"..string.rep("=",sound_volume*10)..string.rep("-",10-sound_volume*10).."|",
			"BACK"
		}
	end
	options_menu:update()

	options_menu.metakeypressed = options_menu.keypressed
	function options_menu:keypressed(k,uni)
		if k == "left" then
			if self.selected == 1 then
				setScale(SCALE-1)
				love.audio.play(snd.Blip)
			elseif self.selected == 2 then
				if SCROLL_SPEED > 3 then
					SCROLL_SPEED = SCROLL_SPEED - 1
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			elseif self.selected == 3 then
				if music_volume >= 0.1 then
					music_volume = music_volume - 0.1
					updateVolumes()
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			elseif self.selected == 4 then
				if sound_volume >= 0.1 then
					sound_volume = sound_volume - 0.1
					updateVolumes()
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			end
			self:update()
		elseif k == "right" then
			if self.selected == 1 then
				setScale(SCALE+1)
				love.audio.play(snd.Blip)
			elseif self.selected == 2 then
				if SCROLL_SPEED < 9 then
					SCROLL_SPEED = SCROLL_SPEED + 1
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			elseif self.selected == 3 then
				if music_volume <= 0.9 then
					music_volume = music_volume + 0.1
					updateVolumes()
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			elseif self.selected == 4 then
				if sound_volume <= 0.9 then
					sound_volume = sound_volume + 0.1
					updateVolumes()
					love.audio.play(snd.Blip)
				else
					love.audio.play(snd.Blip2)
				end
			end
			self:update()
		else
			self:metakeypressed(k,uni)
		end
	end

	-- MAIN MENU
	main_menu = Menu.create(
		{"START GAME", "OPTIONS", "STATS", "CREDITS", "QUIT GAME"},
		{function() gamestate = STATE_LEVEL_MENU end,
		 function() current_menu = options_menu end,
		 function() current_menu = stats_menu end,
		 function() current_menu = credits_menu end,
		 function() love.event.quit() end},

		 function() love.event.quit() end
	)

	function main_menu:draw()
		lg.setColor(255,255,255,255)
		for i=1,self.length do
			if i == self.selected then
				lg.printf("* "..self.names[i].." *", 123, 59+(i-1)*12, 166, "center")
			else
				lg.printf(self.names[i], 123, 59+(i-1)*12, 166, "center")
			end
		end
	end

	-- credits menu
	credits_menu = Menu.create(
		{"GRAPHICS AND PROGRAMMING","SIMON LARSEN","TITLE SCREEN",
		 "LUKAS HANSEN","MUSIC","RUGAR - A SCENT OF EUROPE","SEE LICENCE.TXT FOR MORE INFO"},
		nil,nil
	)
	function credits_menu:draw()
		local top = (HEIGHT-self.height)/2

		lg.setColor(0,0,0,200)
		lg.rectangle("fill",(WIDTH-self.width)/2-6, top-6, self.width+12, self.height+12)
		lg.setColor(255,255,255,255)

		lg.setFont(fontBold)
		local offset = top+8
		for i=1,self.length do
			lg.printf(self.names[i], 0, offset, WIDTH, "center")
			offset = offset + 10
			if (i%2) == 0 then offset = offset + 8 end
		end
	end

	function credits_menu:keypressed(k,uni)
		love.audio.play(snd.Blip)
		current_menu = main_menu
	end

	-- stats menu
	stats_menu = Menu.create(
		{"TOTAL DEATHS: XXX", "TOTAL JUMPS: XXXX", "COINS COLLECTED: 00/45"},
		nil, nil
	)
	function stats_menu:draw()
		local top = (HEIGHT-self.height)/2

		lg.setColor(0,0,0,200)
		lg.rectangle("fill",(WIDTH-self.width)/2-6, top-6, self.width+12, self.height+12)
		lg.setColor(255,255,255,255)

		lg.setFont(fontBold)
		lg.printf("TOTAL DEATHS: "..deaths, 0, top, WIDTH, "center")
		lg.printf("TOTAL JUMPS: "..jumps, 0, top+16, WIDTH, "center")
		lg.printf("COINS COLLECTED: "..coins.."/45", 0, top+32, WIDTH, "center")
	end

	function stats_menu:keypressed(k,uni)
		love.audio.play(snd.Blip)
		current_menu = main_menu
	end
end
