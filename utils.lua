-- Four Languages quiz game (c) Rachel J. Morris 2013, Moosader.com - zlib license

utils = {}

function utils:getSizeOfTable( tbl )
	count = 0
	
	for key, value in pairs( tbl ) do
		count = count + 1
	end
	
	return count
end

function utils:getEntryAtIndex( tbl, index )
	count = 0
	
	for key, value in pairs( tbl ) do
		count = count + 1
		
		if ( count == index ) then
			return value
		end
	end
end

function utils:getKeyAtIndex( tbl, index )
	count = 0
	
	for key, value in pairs( tbl ) do	
		count = count + 1	
		
		if ( count == index ) then
			return key
		end
	end
end

function utils:getRandomNumberWithExclusions( minVal, maxVal, exclude )
	rand = math.random( minVal, maxVal )
	
	badValue = true
	
	while ( badValue ) do
		rand = math.random( minVal, maxVal )
	
		badValue = false
		for key, value in ipairs( exclude ) do
			if ( rand == value ) then
				badValue = true
			end
		end
	end
	
	return rand
end

function utils:getKeyFromValue( tbl, val )
	for key, value in pairs( tbl ) do
		if ( value == val ) then
			return key
		end
	end
end

function utils:printTableData( tbl, indentation )
	io.write( "\n" )
	for key, value in pairs( tbl ) do
		if ( type( value ) == "table" ) then
			for i = 1, indentation do
				io.write( " " )
			end
			io.write( key .. " = " )
			self:printTableData( value, indentation + 1 )
		elseif ( type( value ) == "boolean" ) then
			io.write( "," )
			for i = 1, indentation do
				io.write( " " )
			end
			io.write( key .. " = " )
			
			if ( value == true ) then io.write( "true" ) else io.write( "false" ) end
		else
			io.write( "," )
			for i = 1, indentation do
				io.write( " " )
			end
			io.write( key .. " = " .. value )
		end
	end
end
