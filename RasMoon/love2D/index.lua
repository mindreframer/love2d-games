local s = New.State("index")

s.update = function(dt)
	      print('this is working!!!')
           end

s.draw = function()
	 end

s.onEnter = function()
	       --Load your ressources here
	    end

s.onLeave = function()
	    end

s.mousepressed = function(x, y, button)
		 end

s.mousereleased = function(x, y, button)
		  end

s.keypressed = function(key, unicode)
	       end

s.keyreleased = function(key, unicode)
		  end

s.focus = function(f)
	  end
