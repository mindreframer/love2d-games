-- Four Languages quiz game (c) Rachel J. Morris 2013, Moosader.com - zlib license

require "questions/questions"

require "ui"
require "utils" 

currWord = 0

btnForeignWords = {}
btnForeignWords[1] = { x = 100, y = 200, w = 150, h = 50, enabled = true, language = "" }
btnForeignWords[2] = { x = 100, y = 300, w = 150, h = 50, enabled = true, language = "" }
btnForeignWords[3] = { x = 100, y = 400, w = 150, h = 50, enabled = true, language = "" }
btnForeignWords[4] = { x = 100, y = 500, w = 150, h = 50, enabled = true, language = "" }

btnLanguageNames = {}
btnLanguageNames[1] = { x = 550, y = 200, w = 150, h = 50, enabled = true, language = "" }
btnLanguageNames[2] = { x = 550, y = 300, w = 150, h = 50, enabled = true, language = "" }
btnLanguageNames[3] = { x = 550, y = 400, w = 150, h = 50, enabled = true, language = "" }
btnLanguageNames[4] = { x = 550, y = 500, w = 150, h = 50, enabled = true, language = "" }

clicks = { first = 0, second = 0, cooldown = 0 }

score = { totalWords = 0, totalMatches = 0, totalGuesses = 0, lastGuess = "", lastGuessCounter = 0 }

function love.load()
	chooseNewQuestion()
end

function love.update()
	if ( clicks.cooldown > 0 ) then
		clicks.cooldown = clicks.cooldown - 1
	end

	-- Handle click
	if ( love.mouse.isDown( "l" ) and clicks.cooldown <= 0 ) then
		clicks.cooldown = 25
		-- Handle mouse click
		for i = 1, 4 do
			if ( mouse:isMouseOverTable( btnLanguageNames[i] ) ) then
				clicks.first = i
			elseif ( mouse:isMouseOverTable( btnForeignWords[i] ) ) then
				clicks.second = i
			end
		end
		
		if ( clicks.first ~= 0 and clicks.second ~= 0 ) then
			score.totalGuesses = score.totalGuesses + 1
			score.lastGuessCounter = 50
			
			-- Two items have been matched : Check whether it's correct
			if ( btnLanguageNames[ clicks.first ].language == btnForeignWords[ clicks.second ].language ) then
				-- Correct!
				score.lastGuess = "correct"
				btnLanguageNames[ clicks.first ].enabled = false
				btnForeignWords[ clicks.second ].enabled = false
				btnLanguageNames[ clicks.first ].match = btnForeignWords[ clicks.second ]
				
				score.totalMatches = score.totalMatches + 1
			else
				-- Incorrect!
				score.lastGuess = "incorrect"
			end
			
			-- Reset clicks
			clicks.first = 0
			clicks.second = 0
		end
	end
	
	-- Check to see if everything has been matched
	isAllMatched = true
	for key, btnLanguage in pairs( btnLanguageNames ) do
		if ( btnLanguage.match == nil ) then
			isAllMatched = false
		end
	end
	
	if ( isAllMatched ) then
		-- Next word!
		chooseNewQuestion()
	end
end

function love.draw()	
	ui:drawBackground()
	
	ui:drawHeader( utils:getKeyFromValue( words, currWord ), 0, 50, { r = 255, g = 255, b = 255 } )
	
	if ( score.lastGuessCounter > 0 and score.lastGuess == "correct" ) then
		ui:drawHeader( "Correct!", 0, 100, { r = 0, g = 138, b = 0 } )
	elseif ( score.lastGuessCounter > 0 and score.lastGuess == "incorrect" ) then
		ui:drawHeader( "Incorrect!", 0, 100, { r = 138, g = 0, b = 0 } )
	end

	-- Foreign words
	for key, btnWord in pairs( btnForeignWords ) do
		if ( btnWord.enabled == true ) then
			ui:drawPrimaryButton( currWord[ btnWord.language ], btnWord.x, btnWord.y, btnWord.w, btnWord.h )
		else
			ui:drawDisabledButton( currWord[ btnWord.language ], btnWord.x, btnWord.y, btnWord.w, btnWord.h )
		end
	end
	
	-- Language names to match up
	for key, btnLanguage in pairs( btnLanguageNames ) do
		if ( btnLanguage.enabled == true ) then
			ui:drawSecondaryButton( btnLanguage.language, btnLanguage.x, btnLanguage.y, btnLanguage.w, btnLanguage.h )
		else
			ui:drawDisabledButton( btnLanguage.language, btnLanguage.x, btnLanguage.y, btnLanguage.w, btnLanguage.h )
		end
		
		-- Draw line between matching buttons, if they've already been matched
		if ( btnLanguage.match ~= nil ) then
			
			love.graphics.setColor( 0, 0, 0, 255 )
			x1 = btnLanguage.x + btnLanguage.w / 2
			y1 = btnLanguage.y + btnLanguage.h / 2
			x2 = btnLanguage.match.x + btnLanguage.match.w / 2
			y2 = btnLanguage.match.y + btnLanguage.match.h / 2
			love.graphics.line( x1, y1, x2, y2 )		
		end
	end
	
	-- Draw click-points
	if ( clicks.first ~= 0 ) then
		love.graphics.setColor( 255, 0, 0, 255 )
		xval = btnLanguageNames[ clicks.first ].x + (btnLanguageNames[ clicks.first ].w / 2)
		yval = btnLanguageNames[ clicks.first ].y + (btnLanguageNames[ clicks.first ].h / 2)
		
		love.graphics.circle( "line", xval, yval, 50 )		
		love.graphics.line( xval, yval, love.mouse.getX(), love.mouse.getY() )
	end
	if ( clicks.second ~= 0 ) then
		love.graphics.setColor( 255, 0, 0, 255 )
		xval = btnForeignWords[ clicks.second ].x + (btnForeignWords[ clicks.second ].w / 2)
		yval = btnForeignWords[ clicks.second ].y + (btnForeignWords[ clicks.second ].h / 2)
		
		love.graphics.circle( "line", xval, yval, 50 )
		love.graphics.line( xval, yval, love.mouse.getX(), love.mouse.getY() )
	end
	
	-- Print score
	scoreText = "Total Words: " .. score.totalWords .. ","
	for i = 0, 10 do
		scoreText = scoreText .. " "
	end
	scoreText = scoreText .. "Total Guesses: " .. score.totalGuesses .. ", "
	
	for i = 0, 10 do
		scoreText = scoreText .. " "
	end
	scoreText = scoreText .. "Total Correct: " .. score.totalMatches
	
	ui:drawScore( scoreText, 0, 0, { r = 88, g = 14, b = 140 } )
end

function chooseNewQuestion()
	score.totalWords = score.totalWords + 1
	randIndex = math.random( 1, utils:getSizeOfTable( words ) )
	currWord = utils:getEntryAtIndex( words, randIndex )
	
	w = 150
	h = 50
	
	excludeWords = {}
	excludeLanguages = {}
	-- Randomly assign buttons to word / language
	-- Keep a list of words/languages that have been used, and exclude from random selection.
	for index = 1, 4 do
		randIndex = utils:getRandomNumberWithExclusions( 1, 4, excludeWords )
		btnForeignWords[index].language = utils:getKeyAtIndex( currWord, randIndex )
		btnForeignWords[index].enabled = true
		table.insert( excludeWords, randIndex )		
		
		randIndex = utils:getRandomNumberWithExclusions( 1, 4, excludeLanguages )
		btnLanguageNames[index].language = utils:getKeyAtIndex( currWord, randIndex )
		btnLanguageNames[index].enabled = true
		btnLanguageNames[index].match = nil
		table.insert( excludeLanguages, randIndex )
	end
	
	-- debug
	--print( "FOREIGN WORDS: " )
	--utils:printTableData( btnForeignWords, 0 )
	--print( "\n" )
	
	--print( "LANGUAGES: " )
	--utils:printTableData( btnLanguageNames, 0 )
	--print( "\n" )
end
