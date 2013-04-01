require 'middleclass'

function DUCountAll(f)
	local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function DUTypeCount()
	local counts = {}
	local enumerate = function (o)
		local t 
		if not pcall(function () t = tostring(o.class.name) end) then
		    if not pcall(function () t = type(o) end) then
		        t = "__other__"
		    end
		end
		counts[t] = (counts[t] or 0) + 1
	end
	DUCountAll(enumerate)
	return counts
end

