--[[

Copyright (C) 2011-2012 RasMoon Developpement team

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.


]]-- 

Data = {}

Data.Copy = function(object)
	       local lookup_table = {}
	       local function _copy(object)
		  if type(object) ~= "table" then
		     return object
		  elseif lookup_table[object] then
		     return lookup_table[object]
		  end
		  local new_table = {}
		  lookup_table[object] = new_table
		  for index, value in pairs(object) do
		     new_table[_copy(index)] = _copy(value)
		  end
		  return setmetatable(new_table, _copy(getmetatable(object)))
	       end
	       return _copy(object)
	    end

table.copy = Data.Copy

--[[
   Save Table to File
   Load Table from File
   v 1.0
   
   Lua 5.2 compatible
   
   Only Saves Tables, Numbers and Strings
   Insides Table References are saved
   Does not save Userdata, Metatables, Functions and indices of these
   ----------------------------------------------------
   table.save( table , filename )
   
   on failure: returns an error msg
   
   ----------------------------------------------------
   table.load( filename or stringtable )
   
   Loads a table that has been saved via the table.save function
   
   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   
   Licensed under the same terms as Lua itself.
]]--

-- declare local variables
--// exportstring( string )
--// returns a "Lua" portable version of the string
local function exportstring( s )
   return string.format("%q", s)
end

--// The Save Function
function table.save(  tbl,filename )
   local charS,charE = "   ","\n"
   local file,err = io.open( filename, "wb" )
   if err then return err end

   -- initiate variables for save procedure
   local tables,lookup = { tbl },{ [tbl] = 1 }
   file:write( "return {"..charE )

   for idx,t in ipairs( tables ) do
      file:write( "-- Table: {"..idx.."}"..charE )
      file:write( "{"..charE )
      local thandled = {}

      for i,v in ipairs( t ) do
	 thandled[i] = true
	 local stype = type( v )
	 -- only handle value
	 if stype == "table" then
	    if not lookup[v] then
	       table.insert( tables, v )
	       lookup[v] = #tables
	    end
	    file:write( charS.."{"..lookup[v].."},"..charE )
	 elseif stype == "string" then
	    file:write(  charS..exportstring( v )..","..charE )
	 elseif stype == "number" then
	    file:write(  charS..tostring( v )..","..charE )
	 end
      end

      for i,v in pairs( t ) do
	 -- escape handled values
	 if (not thandled[i]) then
            
	    local str = ""
	    local stype = type( i )
	    -- handle index
	    if stype == "table" then
	       if not lookup[i] then
		  table.insert( tables,i )
		  lookup[i] = #tables
	       end
	       str = charS.."[{"..lookup[i].."}]="
	    elseif stype == "string" then
	       str = charS.."["..exportstring( i ).."]="
	    elseif stype == "number" then
	       str = charS.."["..tostring( i ).."]="
	    end
            
	    if str ~= "" then
	       stype = type( v )
	       -- handle value
	       if stype == "table" then
		  if not lookup[v] then
		     table.insert( tables,v )
		     lookup[v] = #tables
		  end
		  file:write( str.."{"..lookup[v].."},"..charE )
	       elseif stype == "string" then
		  file:write( str..exportstring( v )..","..charE )
	       elseif stype == "number" then
		  file:write( str..tostring( v )..","..charE )
	       end
	    end
	 end
      end
      file:write( "},"..charE )
   end
   file:write( "}" )
   file:close()
end

Data.Save = table.save

function table.restore( sfile )
   local ftables,err = loadfile( sfile )
   if err then return _,err end
   local tables = ftables()
   for idx = 1,#tables do
      local tolinki = {}
      for i,v in pairs( tables[idx] ) do
	 if type( v ) == "table" then
	    tables[idx][i] = tables[v[1]]
	 end
	 if type( i ) == "table" and tables[i[1]] then
	    table.insert( tolinki,{ i,tables[i[1]] } )
	 end
      end
      -- link indices
      for _,v in ipairs( tolinki ) do
	 tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
      end
   end
   return tables[1]
end

Data.Restore = table.restore


New = {}

New.Stack = function(t)
	       local res = {
		  push = function(self, ...)
			    for _,v in ipairs{...} do
			       self[#self + 1] = v
			    end
			 end,
		  pop = function(self)
			   return(table.remove(self))
			end,
		  get = function(self)
			   return(self[#self])
			end,
		  size = function(self)
			    return (#self)
			 end
	       }
	       return setmetatable(t or {}, {__index = res})
	    end

New.PriorityQueue = function(sorter)
		       local res = {
			  push = function(self, ...)
				    for _,v in ipairs{...} do
				       self[#self + 1] = v
				    end
				    table.sort(self, self.sorter)
				 end,
			  pop = function(self)
				   return(table.remove(self))
				end,
			  get = function(self)
				   return(self[#self])
				end,
			  size = function(self)
				    return (#self)
				 end,
			  sorter = sorter or function(a,b) return a > b end
		       }
		       return setmetatable(t or {}, {__index = res})
		    end

New.Queue = function(t)
	       local res = {
		  l = {
		     b = 1,
		     e = 1,
		  },
		  push = function(self, ...)
			    for _, v in ipairs{...} do
			       self[self.l.e] = v
			       self.l.e = self.l.e + 1
			    end
			 end,
		  pop = function(self)
			   local res
			   if self.l.b ~= self.l.e then
			      res = self[self.l.b]
			      self[self.l.b] = nil
			      self.l.b = self.l.b + 1
			   end
			   return (res)
			end,
		  get = function(self)
			   local res
			   if self.l.b ~= self.l.e then
			      res = self[self.l.b]
			   end
			   return (res)
			end,
		  size = function(self)
			    return (self.l.e - self.l.b)
			 end
	       }
	       return setmetatable(t or {}, {__index = res})
	    end

New.UID = function(t)
	     local res = {
		current = 0,
		get = function(self)
			 self.current = self.current + 1
			 return (self.current)
		      end
	     }
	     return setmetatable(t or {}, {__index = res})
	  end

New.Observer = function(t, callback)
		  local index = {}
		  local mt = {
		     __index = function (t,k)
				  callback(t[index][k])
				  return t[index][k]
			       end,

		     __newindex = function (t,k,v)
				     callback(t[index][k], v)
				     t[index][k] = v
				  end
		  }
		  local res = {}
		  res[index] = t
		  setmetatable(res, mt)
		  return res
	       end

table.observer = New.Observer

New.File = function(param)
	      assert(nil ~= param and type(param) == "string")
	      local res = ""
	      local file = io.open(param, "r")
	      if file ~= nil then
		 res = file:read("*all")
		 file:close()
	      end
	      return (res:split("\n"))
	   end

