function update_gameplay(dt)
  jet:setPosition(sm_pos_x - 10 * math.sin(sm_ang), sm_pos_y + 10 * math.cos(sm_ang))
  jet:setDirection(sm_ang + math.pi / 2)
  jet:update(dt)
  --smoke:setSpeed(50 - math.sqrt(sm_v_x^2 + sm_v_x^2) * math.cos(sm_ang - math.pi / 2 - math.atan2(sm_v_y, sm_v_x)), 100 - math.sqrt(sm_v_x^2 + sm_v_x^2) * math.cos(sm_ang - math.pi / 2 - math.atan2(sm_v_y, sm_v_x)))
  smoke:setPosition(sm_pos_x - 10 * math.sin(sm_ang), sm_pos_y + 10 * math.cos(sm_ang))
  smoke:setDirection(sm_ang + math.pi / 2 + 0.25 * math.sin(20 * love.timer.getTime()))
  smoke:update(dt)
  smr:update(dt)
  blood:update(dt)
  explosion:update(dt)
  expsmoke:update(dt)

  mt2 = love.timer.getMicroTime()
  if level_loaded then
    for i = 1, numplanets, 1 do
      p_oldpos_x[i] = p_pos_x[i]
      p_oldpos_y[i] = p_pos_y[i]
      p_v_x[i] = 0
      p_v_y[i] = 0
    end
    mt1 = mt2
    level_loaded = false
  elseif mt2 - mt1 > 0.1 then							-- Calculate planet velocities
    for i = 1, numplanets, 1 do
      p_v_x[i] = (p_pos_x[i] - p_oldpos_x[i]) / (mt2 - mt1)
      p_v_y[i] = (p_pos_y[i] - p_oldpos_y[i]) / (mt2 - mt1)
      p_dir[i] = math.atan2(p_v_y[i], p_v_x[i])
      p_speed[i] = math.sqrt(p_v_x[i]^2 + p_v_x[i]^2)
      p_oldpos_x[i] = p_pos_x[i]
      p_oldpos_y[i] = p_pos_y[i]
    end
    mt1 = mt2
  end

  for i = 1, numplanets, 1 do
    p_ang[i] = p_ang[i] + p_angv[i] * dt
  end

  if thisplanet == 0 then							-- Spaceman drifting in free space
    if thispart > 0 and thispart <= numparts and part_planet[thispart] == 0 and part_visible[thispart] then
      dist = math.sqrt((part_pos_x[thispart] - sm_pos_x)^2 + (part_pos_y[thispart] - sm_pos_y)^2)
      if dist < 40 then thispart = thispart + 1 end
    end
    if fuel < 100 then
      for i = 1, fuel_bottles, 1 do
        if fuel_remaining[i] and fuel_planet[i] == 0 then
          dist = math.sqrt((fuel_pos_x[i] - sm_pos_x)^2 + (fuel_pos_y[i] - sm_pos_y)^2)
          if dist < 40 then
            fuel_remaining[i] = false
            fuel = fuel + 20
            if fuel > 100 then fuel = 100 end
          end
        end
      end
    end

    cam_x = cam_x + ((sm_pos_x - love.graphics.getWidth()/2  - cam_x) * 2 + sm_v_x) * dt
    cam_y = cam_y + ((sm_pos_y - love.graphics.getHeight()/2 - cam_y) * 2 + sm_v_y) * dt
    if love.keyboard.isDown("right") and menu == false and level_finished == false then sm_angv = sm_angv + 40 * dt
    elseif love.keyboard.isDown("left") and menu == false and level_finished == false then sm_angv = sm_angv - 40 * dt
    elseif love.keyboard.isDown("down") then
      if sm_angv > 0 then sm_angv = sm_angv - 20 * dt
      elseif sm_angv < 0 then sm_angv = sm_angv + 20 * dt
      end
      if math.abs(sm_angv) < 1 then sm_angv = 0 end
    end
    if sm_angv > 5 then sm_angv = 5 end
    if sm_angv < -5 then sm_angv = -5 end
    sm_ang = sm_ang + sm_angv * dt
    sm_ang = fix_angle(sm_ang)

    force_x = 0
    force_y = 0
    td = ""
    for i = 1, numplanets, 1 do							-- Check for planet collision
      dist = math.sqrt((p_pos_x[i] - sm_pos_x)^2 + (p_pos_y[i] - sm_pos_y)^2)
      if dist <= p_rad[i] + 25 then
        hitangle = fix_angle(math.atan2((sm_pos_y - p_pos_y[i]), (sm_pos_x - p_pos_x[i])))
        vangle1 = fix_angle(math.atan2(sm_v_y, sm_v_x) + math.pi)
        relvangle1 = fix_angle(math.atan2(sm_v_y - p_v_y[i], sm_v_x - p_v_x[i]) + math.pi)
        speed = math.sqrt((sm_v_x)^2 + (sm_v_y)^2)
        relspeed = math.sqrt((sm_v_x - p_v_x[i])^2 + (sm_v_y - p_v_y[i])^2)
        gcross = relspeed * math.sin(hitangle - vangle1)
        relgcross = relspeed * math.sin(hitangle - relvangle1)
        if p_style[i] == 17 or p_style[i] == 18 then				-- Killed by spike ball or star
          dead = true
          lev_finish_time = love.timer.getTime()
          leveltime = love.timer.getTime() - level_start

          if p_style[i] == 17 then
            blood_v_x = 0.4 * sm_v_x + p_rad[i] * p_angv[i] * math.cos(vangle1 + math.pi/2)
            blood_v_y = 0.4 * sm_v_y + p_rad[i] * p_angv[i] * math.sin(vangle1 + math.pi/2)
            blood:setPosition(sm_pos_x, sm_pos_y)
            blood:setDirection(math.atan2(blood_v_y, blood_v_x))
            blood:setSpeed(0.5 * math.sqrt(blood_v_x^2 + blood_v_y^2), 1 * math.sqrt(blood_v_x^2 + blood_v_y^2))
            blood:setSpread(400 / math.sqrt(blood_v_x^2 + blood_v_y^2))
            blood:start()
          elseif p_style[i] == 18 then
            explosion:setPosition(p_pos_x[i] + p_rad[i] * math.cos(hitangle), p_pos_y[i] + p_rad[i] * math.sin(hitangle))
            explosion:setDirection(hitangle)
            explosion:start()
            expsmoke:setPosition(p_pos_x[i] + p_rad[i] * math.cos(hitangle), p_pos_y[i] + p_rad[i] * math.sin(hitangle))
            expsmoke:setDirection(hitangle)
            expsmoke:start()
          end

          thisplanet = i
          rel_lat = math.atan2((sm_pos_y - p_pos_y[i]), (sm_pos_x - p_pos_x[i])) - p_ang[i]
          lat = rel_lat + p_ang[thisplanet]
          runspeed = 0
          rocket = false
          jet:stop()
          smoke:stop()
        elseif angle_diff(fix_angle(sm_ang - math.pi/2), hitangle) < 1 then	-- Land on planet
          thisplanet = i
          rel_lat = math.atan2((sm_pos_y - p_pos_y[i]), (sm_pos_x - p_pos_x[i])) - p_ang[i]
          lat = rel_lat + p_ang[thisplanet]
          runspeed = relgcross - p_angv[i] * p_rad[i]
          rocket = false
          jet:stop()
          smoke:stop()
        else									-- Bounce off planet
          vangle2 = 2 * hitangle - vangle1
          sm_v_x = p_v_x[i] + math.cos(vangle2) * relspeed * 0.7
          sm_v_y = p_v_y[i] + math.sin(vangle2) * relspeed * 0.7
          sm_pos_x = p_pos_x[i] + (p_rad[i] + 26) * math.cos(hitangle)
          sm_pos_y = p_pos_y[i] + (p_rad[i] + 26) * math.sin(hitangle)

          sm_angv = sm_angv + (0.05 * relgcross - sm_angv)
        end
      end
      if dist ~= 0 and p_mass[i] ~= 0 then
        force = (G * p_mass[i] * sm_mass) / dist^2
        dir_x = (p_pos_x[i] - sm_pos_x) / dist
        dir_y = (p_pos_y[i] - sm_pos_y) / dist
        force_x = force_x + force * dir_x - 0.0002 * sm_v_x 
        force_y = force_y + force * dir_y - 0.0002 * sm_v_y
      end
    end

    if rocket and love.keyboard.isDown("up") and fuel > 0 then
      rocket_on = true
      force_x = force_x + 5 * math.sin(sm_ang)
      force_y = force_y - 5 * math.cos(sm_ang)
      fuel = fuel - 5 * dt
      if fuel < 0 then fuel = 0 end
    else
      rocket_on = false
      jet:stop()
      smoke:stop()
    end

    sm_acc_x = force_x / sm_mass
    sm_acc_y = force_y / sm_mass
    sm_v_x = sm_v_x + sm_acc_x
    sm_v_y = sm_v_y + sm_acc_y
    sm_pos_x = sm_pos_x + sm_v_x * dt
    sm_pos_y = sm_pos_y + sm_v_y * dt

  elseif thisplanet ~= 0 then							-- Spaceman on a planet
    if dead == false and thispart > 0 and thispart <= numparts and part_planet[thispart] == thisplanet and part_visible[thispart] then
      dist = p_rad[thisplanet] * math.abs(fix_angle(rel_lat) - fix_angle(part_rel_lat[thispart]))
      if dist < 40 then thispart = thispart + 1 end
    end
    if fuel < 100 then
      for i = 1, fuel_bottles, 1 do
        if fuel_remaining[i] and fuel_planet[i] == thisplanet then
          dist = p_rad[thisplanet] * math.abs(fix_angle(rel_lat) - fix_angle(fuel_rel_lat[i]))
          if dist < 40 then
            fuel_remaining[i] = false
            fuel = fuel + 20
            if fuel > 100 then fuel = 100 end
          end
        end
      end
    end

    if menu == false then
      if p_rad[thisplanet] < 250 then
        cam_x = cam_x + ((p_pos_x[thisplanet] - love.graphics.getWidth()/2  - cam_x) * 2 + p_v_x[thisplanet]) * dt
        cam_y = cam_y + ((p_pos_y[thisplanet] - love.graphics.getHeight()/2 - cam_y) * 2 + p_v_y[thisplanet]) * dt
      else
        cam_x = cam_x + ((sm_pos_x - love.graphics.getWidth()/2  - cam_x) * 2 + sm_v_x) * dt
        cam_y = cam_y + ((sm_pos_y - love.graphics.getHeight()/2 - cam_y) * 2 + sm_v_y) * dt
      end
    end
    rel_lat = fix_angle(rel_lat)
    lat = fix_angle(lat)
    if love.keyboard.isDown("right") and menu == false and level_finished == false then
      sm_orient = 1
      if runspeed < 0 then runspeed = runspeed + 500 * dt
      else runspeed = runspeed + 200 * dt
      end
    elseif love.keyboard.isDown("left") and menu == false and level_finished == false then
      sm_orient = -1
      if runspeed > 0 then runspeed = runspeed - 500 * dt
      else runspeed = runspeed - 200 * dt
      end
    else
      if runspeed > 0 then
        runspeed = runspeed - 200 * dt
        sm_orient = 1
      elseif runspeed < 0 then
        runspeed = runspeed + 200 * dt
        sm_orient = -1
      end
      if math.abs(runspeed) < 10 then runspeed = 0 end
    end
    rel_lat = rel_lat + (runspeed / p_rad[thisplanet]) * dt
    lat = rel_lat + p_ang[thisplanet]
    sm_pos_x = p_pos_x[thisplanet] + (p_rad[thisplanet] + 23) * math.cos(lat)
    sm_pos_y = p_pos_y[thisplanet] + (p_rad[thisplanet] + 23) * math.sin(lat)
    sm_ang = lat + math.pi/2
    runangle = lat + math.pi/2
    sm_v_x = runspeed * math.cos(runangle)
    sm_v_y = runspeed * math.sin(runangle)
    explosion:setPosition(p_pos_x[thisplanet] + p_rad[thisplanet] * math.cos(lat), p_pos_y[thisplanet] + p_rad[thisplanet] * math.sin(lat))
    expsmoke:setPosition(p_pos_x[thisplanet] + p_rad[thisplanet] * math.cos(lat), p_pos_y[thisplanet] + p_rad[thisplanet] * math.sin(lat))
    for i = 1, numplanets, 1 do
      if dead == false and p_style[i] == 17 and math.sqrt((p_pos_x[i] - sm_pos_x)^2 + (p_pos_y[i] - sm_pos_y)^2) <= p_rad[i] + 25 then
        dead = true
        lev_finish_time = love.timer.getTime()
        leveltime = love.timer.getTime() - level_start

        vangle1 = fix_angle(math.atan2(sm_v_y, sm_v_x) + math.pi)
        blood_v_x = 0.4 * sm_v_x + p_rad[i] * p_angv[i] * math.cos(vangle1 + math.pi/2)
        blood_v_y = 0.4 * sm_v_y + p_rad[i] * p_angv[i] * math.sin(vangle1 + math.pi/2)
        blood:setPosition(sm_pos_x, sm_pos_y)
        blood:setDirection(math.atan2(blood_v_y, blood_v_x))
        blood:setSpeed(0.5 * math.sqrt(blood_v_x^2 + blood_v_y^2), 1 * math.sqrt(blood_v_x^2 + blood_v_y^2))
        blood:setSpread(400 / math.sqrt(blood_v_x^2 + blood_v_y^2))
        blood:start()

        runspeed = 0
        rocket = false
        jet:stop()
        smoke:stop()
      end
    end
  end

  if thispart > 0 and thispart <= numparts and part_planet[thispart] ~= 0 then
    part_pos_x[thispart] = p_pos_x[part_planet[thispart]] + (p_rad[part_planet[thispart]] + 23) * math.cos(part_rel_lat[thispart] + p_ang[part_planet[thispart]])
    part_pos_y[thispart] = p_pos_y[part_planet[thispart]] + (p_rad[part_planet[thispart]] + 23) * math.sin(part_rel_lat[thispart] + p_ang[part_planet[thispart]])
  end
  for i = 1, fuel_bottles, 1 do
    if fuel_remaining[i] and fuel_planet[i] ~= 0 then
      fuel_pos_x[i] = p_pos_x[fuel_planet[i]] + (p_rad[fuel_planet[i]] + 23) * math.cos(fuel_rel_lat[i] + p_ang[fuel_planet[i]])
      fuel_pos_y[i] = p_pos_y[fuel_planet[i]] + (p_rad[fuel_planet[i]] + 23) * math.sin(fuel_rel_lat[i] + p_ang[fuel_planet[i]])
    end
  end

  if thispart > numparts and level_finished == false then
    leveltime = love.timer.getTime() - level_start
    if thislevel == 16 then
      newpb = false
    elseif besttime[thislevel] == 0 then
      besttime[thislevel] = leveltime
      newpb = false
    elseif leveltime < besttime[thislevel] then
      besttime[thislevel] = leveltime
      newpb = true
    else
      newpb = false
    end
    level_finished = true
    lev_finish_time = love.timer.getTime()
    refresh_levels()
  end
end
