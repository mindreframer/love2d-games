--[[
   This is an example of how to use solver.lua

   This example works with Love2D
   https://www.love2d.org/

   This solver and demo is based on the code from 'Real-time Fluid Dynamics for Games' by Jos Stam.
   http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
]]
solver = require "solver"

local N = 32
local N2 = N+2

--Let the solver know what size the grid is
solver.init( N )

function alloc(v)
   v = v or 0.0
   local t,size = {}, (N2)*(N2)
   for i=1,size do t[i] = v end
   return t
end

local dt, diff, visc
local force, source
local dvel

local u,v, u_prev, v_prev = alloc(),alloc(),alloc(),alloc()
local dens, dens_prev = alloc(),alloc()

--Defaults from demo.c
local dt = 0.1;
local diff = 0.0;
local visc = 0.0;
local force = 2.5;
local source = 50.0;
local scaleFactor = love.graphics.getWidth()/N;
local dvel = 0;

--Keep track of mouse and density added.
local iPrev,jPrev = 0,0
local xPrev, yPrev = 0,0
local totalDensity, densityCap = 0, 50

--Density Effect
local densityImageData = love.image.newImageData(N,N)
local quad = love.graphics.newQuad( 0, 0, N*scaleFactor,N*scaleFactor,N*scaleFactor,N*scaleFactor)

local densityEffect = love.graphics.newPixelEffect [[
   const number radius = 0.009;
   
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
   {
      vec4 c = vec4( Texel(texture, texture_coords) );
      float u = texture_coords[0];
      float v = texture_coords[1];

      // Simple blurring effect, otherwise it looks gross.
      c += vec4( Texel(texture, vec2(u,v-radius)) );
      c += vec4( Texel(texture, vec2(u,v+radius)) );
      c += vec4( Texel(texture, vec2(u-radius,v)) );
      c += vec4( Texel(texture, vec2(u+radius,v)) );
      c += vec4( Texel(texture, vec2(u-radius,v-radius)) );
      c += vec4( Texel(texture, vec2(u+radius,v-radius)) );
      c += vec4( Texel(texture, vec2(u+radius,v+radius)) );
      c += vec4( Texel(texture, vec2(u-radius,v+radius)) );
      c /= 9;
      return c;
   }
]]

function updateFluid()
   solver.vel_step ( N, u, v, u_prev, v_prev, visc, dt );
   solver.dens_step ( N, dens, dens_prev, u, v, diff, dt );
   dens_prev,u_prev,v_prev = alloc(),alloc(),alloc()
end

function mouseEvent(x,y)
   local i, j = math.floor(x/scaleFactor), math.floor(y/scaleFactor);
   if  i < 1 or i > N or j < 1 or j > N then return end

   local index = ((i)+(N+2)*(j));

   if totalDensity  < densityCap then
      dens_prev[index] = source;
      totalDensity = totalDensity + 1;
   end

   u[index] = force * (i-iPrev);
   v[index] = force * (j-jPrev);

   iPrev,jPrev = i,j
end

function love.update()

   -- If the mouse moves enough, call mouseEvent(x,y)
   if love.mouse.isDown( "l" ) then
      local xCur, yCur = love.mouse.getPosition()
      if math.sqrt((xCur - xPrev)^2 + (yCur - yPrev)^2) > 1 then
         mouseEvent(xCur, yCur)
      end
      xPrev, yPrev = xCur, yCur
   end

   updateFluid()

   --There should be a better way to do this, but here we convert a table into an image.
   local value, index = 0, 0

   for i=1,N do 
      for j=1,N do
         value = dens[i+N2*j] * 255
         if value > 255 then
            value = 255
         end
         densityImageData:setPixel(i-1,j-1,value,value,value,255)
      end
   end
end

function love.draw()
   love.graphics.setPixelEffect(densityEffect)

   -- Here we make a texture from the imageData and draw a fullscreen quad with that texture
   local img = love.graphics.newImage( densityImageData )
   love.graphics.drawq(img,quad, 0, 0, 0, 1, 1, 0,0)

   --Unset the fragment shader so you can draw other stuff.
   love.graphics.setPixelEffect() 
end

love.graphics.setCaption( "Stable Fluids - click and drag!" )