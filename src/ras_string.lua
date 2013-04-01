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

string.split = function(inputstr, sep)
		  if sep == nil then
		     sep = "%s"
		  end
		  t={} ; i=1
		  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		     t[i] = str
		     i = i + 1
		  end
		  return t
	       end

string.join = function(tab, delim)
                 delim = delim or ""
                 local res = ""
                 for i,v in ipairs(tab) do
                    res = res .. delim .. tostring(v)
                 end
                 return res
	      end

string.starts = function(String, Start)
                   return string.sub(String, 1, string.len(Start)) == Start
                end

string.ends = function(String, End)
                 return End == '' or string.sub(String, -string.len(End)) == End
              end

string.explode = function(self)
		    local l = {}
		    for i = 1 , #self do
		       table.insert(l,self:sub(i,i))
		    end
		    return (l)
		 end

string.stripchar = function(str, chr)
		      local s = ""
		      for g in str:gmatch( "[^"..chr.."]" ) do
			 s = s .. g
		      end
		      return s
		   end
