-- Class: Recorder
-- This records the user's inputs for playback at a later time,
-- or saving to a file. You must start recording *after* all input
-- objects are set up, and you should only run one recorder at a time.
--
-- Extends:
--		<Sprite>

Recorder = Sprite:extend{
	-- private property: elapsed
	-- either time elapsed while recording or playing back, in seconds
	_elapsed = 0,

	-- private property: mousePosTimer
	-- used to make sure mouse motions are recorded even if no other event occurs
	_mousePosTimer = 0,

	-- Constant: IDLE
	-- The recorder is currently doing nothing.
	IDLE = 'idle',

	-- Constant: RECORDING
	-- The recorder is currently recording user input.
	RECORDING = 'recording',

	-- Constant: PLAYING
	-- The recorder is currently playing back user input.
	PLAYING = 'playing',

	-- Property: mousePosInterval
	-- How often, in seconds, we should capture the mouse position.
	-- This records the mouse position when other events occur, too, so
	-- it's possible the interval will be even higher in reality.
	-- Setting this number lower will burn memory.
	mousePosInterval = 0.05,

	-- Property: state
	-- One of the state constants, indicates what the recorder is currently doing.

	-- Property: record
	-- A table of inputs with timing information.

	new = function (self, obj)
		obj = self:extend(obj)
		obj.state = Recorder.IDLE

		Sprite.new(obj)
		return obj
	end,

	-- Method: startRecording
	-- Begins recording user inputs. If the recorder is already recording,
	-- this has no effect.
	--
	-- Arguments:
	--		record - Record to use. Any existing data is appended to.
	--				 If omitted, the current record is used. If the current
	--				 record is unset, this creates a new record.
	--
	-- Returns:
	--		nothing

	startRecording = function (self, record)
		if self.state ~= Recorder.IDLE then return end

		-- set up properties
		self.record = record or self.record or {}
		self.state = Recorder.RECORDING
		self._elapsed = 0
		self._mousePosTimer = 0

		-- insert ourselves into event handlers
		self:stealInputs()
	end,

	-- Method: stopRecording
	-- Stops recording user inputs. If the recorder wasn't recording anyway,
	-- this does nothing.
	-- 
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		nothing

	stopRecording = function (self)
		if self.state ~= Recorder.RECORDING then return end

		self.state = Recorder.IDLE
		self:restoreInputs()
		love.keypressed = self.origKeyPressed
		love.keyreleased = self.origKeyReleased
	end,

	-- Method: startPlaying
	-- Starts playing back user inputs. If this is already playing
	-- a recording, this restarts it.
	--
	-- Arguments:
	--		record - Record to play back. If omitted, this uses
	--				 the recorder's record property.
	--
	-- Returns:
	--		nothing

	startPlaying = function (self, record)
		record = record or self.record

		-- if we are currently recording, ignore the request

		if self.state == Recorder.RECORDING then return end

		-- restart if needed

		if self.state == Recorder.PLAYING then
			self:stopPlaying()	
		end

		self.state = Recorder.PLAYING 

		self._elapsed = 0
		self.playbackIndex = 1
		self:stealInputs()
	end,

	-- Method: stopPlaying
	-- Stops playing back user inputs.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	stopPlaying = function (self)
		if not self.state == Recorder.PLAYING then return end
		self.state = Recorder.IDLE
		self:restoreInputs()
	end,

	stealInputs = function (self)
		local this = self

		self.origKeyPressed = love.keypressed
		love.keypressed = function (key, code) this:recordKeyPress(key, code) end
		self.origKeyReleased = love.keyreleased
		love.keyreleased = function (key, code) this:recordKeyRelease(key, code) end
		self.origMousePressed = love.mousepressed
		love.mousepressed = function (x, y, button) this:recordMousePress(x, y, button) end
		self.origMouseReleased = love.mousereleased
		love.mousereleased = function (x, y, button) this:recordMouseRelease(x, y, button) end
	end,

	restoreInputs = function (self)
		love.keypressed = self.origKeyPressed
		love.keyreleased = self.origKeyReleased
		love.mousepressed = self.origMousePressed
		love.mousereleased = self.origMouseReleased
	end,
	
	recordKeyPress = function (self, key, unicode)
		table.insert(self.record, { self._elapsed, the.mouse.x, the.mouse.y, 'keypress', key, unicode })
		self._mousePosTimer = 0

		if self.origKeyPressed then
			self.origKeyPressed(key, unicode)
		end
	end,

	recordKeyRelease = function (self, key, unicode)
		table.insert(self.record, { self._elapsed, the.mouse.x, the.mouse.y, 'keyrelease', key, unicode })
		self._mousePosTimer = 0

		if self.origKeyReleased then
			self.origKeyReleased(key, unicode)
		end
	end,

	recordMousePress = function (self, x, y, button)
		table.insert(self.record, { self._elapsed, x, y, 'mousepress', button })
		self._mousePosTimer = 0

		if self.origMousePressed then
			self.origMousePressed(x, y, button)
		end
	end,

	recordMouseRelease = function (self, x, y, button)
		table.insert(self.record, { self._elapsed, x, y, 'mouserelease', button })
		self._mousePosTimer = 0

		if self.origMouseReleased then
			self.origMouseReleased(x, y, button)
		end
	end,

	update = function (self, elapsed)
		-- increment timers

		if self.state ~= Recorder.IDLE then
			self._elapsed = self._elapsed + elapsed
		end

		-- record mouse position if the timer has expired

		if self.state == Recorder.RECORDING then
			self._mousePosTimer = self._mousePosTimer + elapsed

			if self._mousePosTimer > self.mousePosInterval then
				table.insert(self.record, { self._elapsed, the.mouse.x, the.mouse.y })

				self._mousePosTimer = 0
			end
		end

		-- handle playback

		if self.state == Recorder.PLAYING and self._elapsed >= self.record[self.playbackIndex][1] then
			local event = self.record[self.playbackIndex]
	
			love.mouse.setPosition(event[2], event[3])

			if event[4] == 'keypress' and self.origKeyPressed then
				self.origKeyPressed(event[5], event[6])
			elseif event[4] == 'keyrelease' and self.origKeyReleased then
				self.origKeyReleased(event[5], event[6])
			elseif event[4] == 'mousepress' and self.origMousePressed then
				self.origMousePressed(event[2], event[3], event[5])
			elseif event[4] == 'mouserelease' and self.origMouseReleased then
				self.origMouseReleased(event[2], event[3], event[5])
			end

			self.playbackIndex = self.playbackIndex + 1

			if self.playbackIndex > #self.record then
				self:stopPlaying()
			end
		end
	end
}
