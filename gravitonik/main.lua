love.filesystem.load("menus.lua")()
love.filesystem.load("gameplay.lua")()
love.filesystem.load("functions.lua")()
love.filesystem.load("AnAL.lua")()
love.filesystem.setIdentity("gravitonik")

function love.load()
  files = {}
  filematch = {}
  mm_option = {}
  mm_opt_val = {}
  levmen_min = 0
  levmen_max = 0
  usrmen_min = 0
  usrmen_max = 0
  menufont = love.graphics.newFont("gfx/Prototype.ttf", 42)
  textfont = love.graphics.newFont("gfx/Prototype.ttf", 26)

  td = ""

  level_name = {}
  level_name[1] = "Space Walk"
  level_name[2] = "A Little Further"
  level_name[3] = "Asteroid Belt"
  level_name[4] = "Leap of Faith"
  level_name[5] = "Deep Space"
  level_name[6] = "Orbituary"
  level_name[7] = "[Placeholder]"
  level_name[8] = "Planetary System"
  level_name[9] = "[Placeholder]"
  level_name[10] = "Binary System"
  level_name[11] = "Spike System"
  level_name[12] = "Ultragravity"
  level_name[13] = "Spikes of Doom"
  level_name[14] = "Platformer"
  level_name[15] = "Antigravity"

  math.randomseed(os.time())
  sm_mass = 1
  cam_x = 0
  cam_y = 0
  cam_o_x = 0
  cam_o_y = 0
  cam_n_x = 0
  cam_n_y = 0
  force = 0
  force_x = 0
  force_y = 0
  dist = 0
  dir_x = 0
  dir_y = 0
  G = 0.2
  lat = 0
  hitangle = 0
  vangle1 = 0
  relvangle1 = 0
  vangle2 = 0
  speed = 0
  bounce = false
  gcross = 0
  relgcross = 0
  blood_v_x = 0
  blood_v_y = 0
  runangle = 0
  runtime = 0
  i = 0
  j = 0
  rocket = false
  rocket_on = false
  fuel = 100
  level_loaded = true
  level_finished = false
  paused = false
  dead = false
  lev_finish_time = 0
  menu = true
  name_table = {}
  name = ""
  name_error = ""
  can_jump = true
  firsthalf = true
  change_dist = 0
  fuel_planet = {}
  fuel_rel_lat = {}
  mt1 = love.timer.getMicroTime()
  mt2 = mt1
  love.graphics.setBackgroundColor(0,0,0)

  numlevels = 15
  lev_option = {}
  lev_opt_val = {}
  lev_options = 0
  lev_selected = 1
  uptolevel = 1
  leveltime = 0
  newpb = false
  besttime = {}
  for i = 1, numlevels, 1 do
    besttime[i] = 0
  end

  title = love.graphics.newImage("gfx/gravitonik-title.png")
  cc = love.graphics.newImage("gfx/cc-by-nc-sa80x15.png")
  lovelogo = love.graphics.newImage("gfx/lovelogo.png")
  bg = love.graphics.newImage("gfx/starbg.png")
  flame = love.graphics.newImage("gfx/flame.png")
  particon = love.graphics.newImage("gfx/particon.png")
  bottle = love.graphics.newImage("gfx/fuelbottle.png")
  arrow = love.graphics.newImage("gfx/arrow.png")
  glow = love.graphics.newImage("gfx/glow.png")
  windowicon = love.graphics.newImage("gfx/window-icon.png")
  love.graphics.setIcon(windowicon)
  sms = love.graphics.newImage("gfx/spaceman-stand.png")
  smj = love.graphics.newImage("gfx/spaceman-jump.png")
  smr_img = love.graphics.newImage("gfx/spaceman-run.png")
  smr = newAnimation(smr_img, 512, 512, 0.05, 4)
  smr:setDelay(1, 0.15)
  smr:setDelay(2, 0.05)
  smr:setDelay(3, 0.15)
  smr:setDelay(4, 0.05)
  smr:play()

  planet = {}
  for i = 1, 24, 1 do
    planet[i] = love.graphics.newImage("gfx/planet" .. pad_zeros(i, 4) .. ".png")
  end

  part = {}
  part[1] = love.graphics.newImage("gfx/part1.png")
  part[2] = love.graphics.newImage("gfx/part2.png")
  part[3] = love.graphics.newImage("gfx/part3.png")

  p_pos_x = {}
  p_pos_y = {}
  p_oldpos_x = {}
  p_oldpos_y = {}
  p_v_x = {}
  p_v_y = {}
  p_dir = {}
  p_speed = {}
  p_rad = {}
  p_density = {}
  p_mass = {}
  p_ang = {}
  p_ang[0] = 0
  p_angv = {}
  p_style = {}

  part_planet = {}
  part_rel_lat = {}
  part_pos_x = {}
  part_pos_y = {}
  part_style = {}
  part_ang = {}
  part_visible = {}
  fuel_remaining = {}
  fuel_pos_x = {}
  fuel_pos_y = {}
  fuel_ang = {}

  init_menu()
  refresh_levels()

  part1 = love.graphics.newImage("gfx/particle.png")
  jet = love.graphics.newParticleSystem(part1, 1000)
  jet:setEmissionRate(500)
  jet:setLifetime(-1)
  jet:setParticleLife(0.1, 0.2)
  jet:setSpeed(200, 700)
  jet:setSpread(0.2)
  jet:setRadialAcceleration(-20, -10)
  jet:setSizes(0.3, 0.5)
  jet:setSizeVariation(1)
  jet:setColors(255, 255, 255, 255, 127, 127, 255, 0)
  jet:stop()
  smoke = love.graphics.newParticleSystem(part1, 2000)
  smoke:setEmissionRate(500)
  smoke:setLifetime(-1)
  smoke:setParticleLife(1, 3)
  smoke:setSpeed(50, 100)
  smoke:setSpread(0.5)
  smoke:setRadialAcceleration(-20, -10)
  smoke:setSizes(0.4, 0.7)
  smoke:setSizeVariation(1)
  smoke:setColors(191, 191, 191, 255, 191, 191, 191, 0)
  smoke:stop()
  blood = love.graphics.newParticleSystem(part1, 2000)
  blood:setEmissionRate(1000)
  blood:setLifetime(0.1)
  blood:setParticleLife(0.5, 1)
  blood:setRadialAcceleration(-20, -10)
  blood:setSizes(0.1, 0.7)
  blood:setSizeVariation(1)
  blood:setColors(255, 0, 0, 255, 255, 0, 0, 0)
  blood:stop()
  explosion = love.graphics.newParticleSystem(part1, 2000)
  explosion:setEmissionRate(2000)
  explosion:setLifetime(0.2)
  explosion:setParticleLife(0.5, 1.5)
  explosion:setSpeed(50, 200)
  explosion:setSpread(math.pi)
  explosion:setRadialAcceleration(-20, -10)
  explosion:setSizes(0.1, 0.7)
  explosion:setSizeVariation(1)
  explosion:setColors(255, 255, 0, 255, 255, 127, 0, 0)
  explosion:stop()
  expsmoke = love.graphics.newParticleSystem(part1, 2000)
  expsmoke:setEmissionRate(500)
  expsmoke:setLifetime(1)
  expsmoke:setParticleLife(1.5, 3)
  expsmoke:setSpeed(50, 100)
  expsmoke:setSpread(math.pi)
  expsmoke:setRadialAcceleration(-20, -10)
  expsmoke:setSizes(0.4, 0.7)
  expsmoke:setSizeVariation(1)
  expsmoke:setColors(191, 191, 191, 255, 191, 191, 191, 0)
  expsmoke:stop()
end

function love.update(dt)
  if menu then update_menus(dt)
  else update_level(dt)
  end
  if paused == false then update_gameplay(dt)
  end

end

function love.draw()
  love.graphics.setColorMode("replace")
  drawbg()

  love.graphics.setColorMode("modulate")
  love.graphics.draw(smoke, -cam_x, -cam_y)
  love.graphics.draw(jet, -cam_x, -cam_y)

  love.graphics.setColorMode("replace")
  for j = 1, numplanets, 1 do
    if p_style ~= 0 then love.graphics.draw(planet[p_style[j]], p_pos_x[j] - cam_x, p_pos_y[j] - cam_y, p_ang[j], p_rad[j] / 256, p_rad[j] / 256, 512, 512) end
    if thisplanet == j and dead == false and runspeed ~= 0 then
      smr:draw(sm_pos_x - cam_x, sm_pos_y - cam_y, sm_ang, 0.125 * sm_orient, 0.125, 256, 256)
    elseif thisplanet == j and dead == false then
      love.graphics.draw(sms, sm_pos_x - cam_x, sm_pos_y - cam_y, sm_ang, 0.125 * sm_orient, 0.125, 256, 256)
    end
  end
  if thisplanet == 0 and rocket_on then
    love.graphics.draw(sms, sm_pos_x - cam_x, sm_pos_y - cam_y, sm_ang, 0.125 * sm_orient, 0.125, 256, 256)
  elseif thisplanet == 0 then
    love.graphics.draw(smj, sm_pos_x - cam_x, sm_pos_y - cam_y, sm_ang, 0.125 * sm_orient, 0.125, 256, 256)
  end

  if menu then								-- Menu screens
    draw_menus()
  else
    if thispart > 0 and thispart <= numparts and part_visible[thispart] then
      love.graphics.setColorMode("replace")
      love.graphics.draw(glow, part_pos_x[thispart] - cam_x, part_pos_y[thispart] - cam_y, 0, 0.18 + 0.02 * math.sin(10 * love.timer.getTime()), 0.18 + 0.02 * math.sin(10 * love.timer.getTime()), 128, 128)
      love.graphics.draw(part[part_style[thispart]], part_pos_x[thispart] - cam_x, part_pos_y[thispart] - cam_y, part_ang[thispart] + p_ang[part_planet[thispart]], 0.125, 0.125, 128, 128)
      if dead == false and part_visible[thispart] then draw_arrow(part_pos_x[thispart], part_pos_y[thispart]) end
    end

    for i = 1, fuel_bottles, 1 do
      if fuel_remaining[i] then
      love.graphics.setColorMode("replace")
        love.graphics.draw(glow, fuel_pos_x[i] - cam_x, fuel_pos_y[i] - cam_y, 0, 0.18 + 0.02 * math.sin(10 * love.timer.getTime()), 0.18 + 0.02 * math.sin(10 * love.timer.getTime()), 128, 128)
        love.graphics.draw(bottle, fuel_pos_x[i] - cam_x, fuel_pos_y[i] - cam_y, fuel_ang[i], 0.125, 0.125, 128, 128)
      end
    end

    love.graphics.setColorMode("replace")				-- OSD
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(flame, 30, love.graphics.getHeight() - 35, 0, 1, 1, 16, 16)
    love.graphics.line(50, love.graphics.getHeight() - 35, 50, love.graphics.getHeight() - 25)
    love.graphics.line(50, love.graphics.getHeight() - 30, 50 + fuel, love.graphics.getHeight() - 30)
    love.graphics.line(150, love.graphics.getHeight() - 35, 150, love.graphics.getHeight() - 25)

    love.graphics.draw(particon, love.graphics.getWidth() - 80, love.graphics.getHeight() - 35, 0, 1, 1, 16, 16)
    love.graphics.setFont(textfont)
    love.graphics.print(numparts - thispart + 1, love.graphics.getWidth() - 60, love.graphics.getHeight() - 50)
    
    love.graphics.setColorMode("modulate")
    love.graphics.draw(blood, -cam_x, -cam_y)
    love.graphics.draw(expsmoke, -cam_x, -cam_y)
    love.graphics.draw(explosion, -cam_x, -cam_y)

    love.graphics.setColorMode("replace")
    if paused then
      love.graphics.setColor(0, 0, 0, 127)
      love.graphics.rectangle("fill", -5, -5, love.graphics.getWidth() + 10, love.graphics.getHeight() + 10)
      love.graphics.setFont(menufont)
      love.graphics.print("Paused", love.graphics.getWidth() / 2 - 70, 200)
    elseif level_finished then
      love.graphics.setColor(0, 0, 0, 127)
      love.graphics.rectangle("fill", -5, -5, love.graphics.getWidth() + 10, love.graphics.getHeight() + 10)
      if love.timer.getTime() - lev_finish_time > 1 then
        love.graphics.setFont(menufont)
        love.graphics.print("Level finished", love.graphics.getWidth() / 2 - 130, 200)
        love.graphics.print("Time: " .. display_time(leveltime), love.graphics.getWidth() / 2 - 125, 400)
        if newpb then
          love.graphics.setFont(textfont)
          love.graphics.print("New personal best!", love.graphics.getWidth() / 2 - 110, 450)
        end
      end
    elseif dead then
      love.graphics.setColor(0, 0, 0, 127)
      love.graphics.rectangle("fill", -5, -5, love.graphics.getWidth() + 10, love.graphics.getHeight() + 10)
      if love.timer.getTime() - lev_finish_time > 1 then
        love.graphics.setFont(menufont)
        love.graphics.print("Dead", love.graphics.getWidth() / 2 - 40, 200)
        love.graphics.print("Time: " .. display_time(leveltime), 400, 400)
      end
    end
  end
  -- Debug stuff
  --love.graphics.setColorMode("replace")
  --love.graphics.setFont(textfont)
  --love.graphics.print("visible", 40, 40)
end

function love.keypressed(k, u)
  if menu and changescreen == false then				-- Process input at menus
    if menu_screen == 1 then				-- Main menu
      if k == "up" then
        mm_selected = mm_selected - 1
        if mm_selected == 0 then mm_selected = mm_options end
      elseif k == "down" then
        mm_selected = mm_selected + 1
        if mm_selected == mm_options + 1 then mm_selected = 1 end
      elseif k == " " or k == "return" then
        change_menu(mm_opt_val[mm_selected])
      elseif k == "escape" then
        love.event.push("q")
      end
    elseif menu_screen == 2 then			-- New game screen
      if table.maxn(name_table) < 20 and (u > 64 and u < 91 or u > 96 and u < 123 or u > 47 and u < 59 or u == 45 or u == 95) then
        table.insert(name_table, string.char(u))
      elseif k == "backspace" then
        table.remove(name_table)
      elseif k == "return" then
        if table.maxn(name_table) == 0 then
          name_error = "Name must contain at least one character"
        elseif love.filesystem.exists("save/" .. name .. ".grvsv.lua") then
          name_error = "Name already taken"
        elseif new_savefile(name) then
          refresh_saves()
          change_menu(4)
        else
          name_error = "Error: Could not write save file"
        end
      elseif k == "escape" then
        change_menu(1)
      end
      name = table.concat(name_table)
    elseif menu_screen == 3 then			-- Load game screen
      if k == "up" then
        lm_selected = lm_selected - 1
        if lm_selected == 0 then lm_selected = lm_options end
      elseif k == "down" then
        lm_selected = lm_selected + 1
        if lm_selected == lm_options + 1 then lm_selected = 1 end
      elseif k == " " or k == "return" then
        load_savefile(lm_option[lm_selected])
        change_menu(4)
      elseif k == "escape" then
        change_menu(1)
      end
    elseif menu_screen == 4 then			-- Select level screen
      if k == "up" then
        lev_selected = lev_selected - 1
        if lev_selected == 0 then lev_selected = uptolevel end
      elseif k == "down" then
        lev_selected = lev_selected + 1
        if lev_selected == uptolevel + 1 then lev_selected = 1 end
      elseif k == " " or k == "return" then
        if lev_opt_val[lev_selected] == 0 then
        else
          load_level(lev_opt_val[lev_selected])
        end
      elseif k == "escape" then
        change_menu(1)
      end
    elseif menu_screen == 5 then			-- How to play screen
      if k == " " or k == "return" then
        change_menu(1)
      elseif k == "escape" then
        change_menu(1)
      end
    end
  elseif level_finished then				-- Level finished
    if love.timer.getTime() - lev_finish_time > 1 and (k == " " or k == "return" or k == "escape") then
      init_menu()
      write_savefile(name)
      menu = true
      level_finished = false
      dead = false
      cam_x = cam_n_x[4]
      cam_y = cam_n_y[4]
      change_menu(4)
    end
  elseif dead then					-- Player dead
    if love.timer.getTime() - lev_finish_time > 1 and (k == " " or k == "return" or k == "escape") then
      init_menu()
      menu = true
      level_finished = false
      dead = false
      cam_x = cam_n_x[4]
      cam_y = cam_n_y[4]
      change_menu(4)
    end
  elseif menu == false then				-- Gameplay
    if paused then
      if k == "return" or k == " " or k == "escape" or k == "kpenter" or k == "p" then
        paused = false
      end
    elseif k == "p" then
      paused = true
    elseif k == "f5" then
      load_level(thislevel)
    elseif k == "up" then
      if thisplanet ~= 0 then						-- Jump off planet
        can_jump = true
        for i = 1, numplanets, 1 do
          dist = math.sqrt((p_pos_x[i] - sm_pos_x)^2 + (p_pos_y[i] - sm_pos_y)^2)
          if i ~= thisplanet and dist <= p_rad[i] + 25 then can_jump = false end
        end
        if can_jump then
          sm_pos_x = p_pos_x[thisplanet] + (p_rad[thisplanet] + 35) * math.cos(lat)
          sm_pos_y = p_pos_y[thisplanet] + (p_rad[thisplanet] + 35) * math.sin(lat)
          sm_v_x = (runspeed + p_angv[thisplanet] * p_rad[thisplanet]) * math.cos(runangle) + 200 * math.cos(lat) + p_v_x[thisplanet]
          sm_v_y = (runspeed + p_angv[thisplanet] * p_rad[thisplanet]) * math.sin(runangle) + 200 * math.sin(lat) + p_v_y[thisplanet]
          sm_angv = runspeed / p_rad[thisplanet] + p_angv[thisplanet]
          thisplanet = 0
        end
      elseif thisplanet == 0 and fuel > 0 then
        jet:start()
        smoke:start()
        rocket = true
      end
    elseif k == "escape" then
      init_menu()
      menu = true
      cam_x = cam_n_x[4]
      cam_y = cam_n_y[4]
      change_menu(4)
    end
  end
end

function love.keyreleased(k)
  if k == "up" and paused == false then
    jet:stop()
    smoke:stop()
  end
end

function update_level(dt)
end
