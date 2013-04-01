function init_menu()
  menu = true
  refresh_saves()
  changescreen = false
  menu_screen = 1
  mm_selected = 1
  lm_selected = 1
  cam_x = 0
  cam_y = 0
  thisplanet = 1
  runspeed = 0
  rel_lat = -math.pi/2
  fuel_bottles = 0

  cam_n_x = {}
  cam_n_y = {}
  cam_n_x[1] = 0	-- Main menu
  cam_n_y[1] = 0
  cam_n_x[2] = 3000	-- New game
  cam_n_y[2] = -2000
  cam_n_x[3] = 3000	-- Load game
  cam_n_y[3] = 2000
  cam_n_x[4] = 6000	-- Select level
  cam_n_y[4] = 0
  cam_n_x[5] = -4000	-- How to play, screen 1
  cam_n_y[5] = -3000

  numplanets = 2
  p_pos_x[1] = cam_n_x[1] + love.graphics.getWidth() / 2
  p_pos_y[1] = cam_n_y[1] + love.graphics.getHeight() + 250
  p_oldpos_x[1] = 0
  p_oldpos_y[1] = 0
  p_rad[1] = 350
  p_density[1] = 1
  p_ang[1] = -math.pi/2
  p_angv[1] = 0.25
  p_style[1] = 1
  p_mass[1] = p_density[1] * p_rad[1]^3

  p_pos_x[2] = cam_n_x[2] + love.graphics.getWidth() - 100
  p_pos_y[2] = cam_n_y[2] + love.graphics.getHeight() - 50
  p_oldpos_x[2] = 0
  p_oldpos_y[2] = 0
  p_rad[2] = 150
  p_density[2] = 1
  p_ang[2] = -math.pi/2
  p_angv[2] = 0.5
  p_style[2] = 2
  p_mass[2] = p_density[1] * p_rad[1]^3

  sm_pos_x = 0
  sm_pos_y = 0
  sm_v_x = 0		-- All velocities in pixels/sec
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0		-- All angles in radians
  sm_angv = 0
  sm_orient = 1

  numparts = 0
  thispart = 0

  start_level = love.timer.getTime()
end

function update_menus(dt)
  if changescreen then
    if firsthalf then
      cam_x = cam_o_x + 10000 / change_dist * (cam_n_x[menu_screen] - cam_o_x) * (love.timer.getTime() - cam_move_time)^2
      cam_y = cam_o_y + 10000 / change_dist * (cam_n_y[menu_screen] - cam_o_y) * (love.timer.getTime() - cam_move_time)^2
      if cam_n_x[menu_screen] > cam_o_x and cam_x > (cam_n_x[menu_screen] + cam_o_x) / 2
      or cam_n_y[menu_screen] > cam_o_y and cam_y > (cam_n_y[menu_screen] + cam_o_y) / 2
      or cam_n_x[menu_screen] < cam_o_x and cam_x < (cam_n_x[menu_screen] + cam_o_x) / 2
      or cam_n_y[menu_screen] < cam_o_y and cam_y < (cam_n_y[menu_screen] + cam_o_y) / 2 then
        firsthalf = false
        cam_move_time = love.timer.getTime() + (love.timer.getTime() - cam_move_time)
      end
    end
    if firsthalf == false then
      cam_x = cam_n_x[menu_screen] - 10000 / change_dist * (cam_n_x[menu_screen] - cam_o_x) * (cam_move_time - love.timer.getTime())^2
      cam_y = cam_n_y[menu_screen] - 10000 / change_dist * (cam_n_y[menu_screen] - cam_o_y) * (cam_move_time - love.timer.getTime())^2
      if love.timer.getTime() >= cam_move_time then
        cam_x = cam_n_x[menu_screen]
        cam_y = cam_n_y[menu_screen]
        changescreen = false
      end
    end
  else
    
  end
end

function draw_menus()
  -- (1) Main menu
  love.graphics.draw(title, cam_n_x[1] + love.graphics.getWidth() / 2 - cam_x, cam_n_y[1] + 60 + 120 * love.graphics.getHeight() / 768 - cam_y, 0, 1, 1, 512, 128)
  love.graphics.setColorMode("replace")
  love.graphics.setFont(menufont)
  love.graphics.setColorMode("modulate")
  for j = 1, mm_options, 1 do
    if j == mm_selected then
      love.graphics.setColor(255, 255, 255, 255)
    else
      love.graphics.setColor(255, 255, 255, 127)
    end
    love.graphics.print(mm_option[j], cam_n_x[1] + love.graphics.getWidth() / 2 - 100 - cam_x, cam_n_y[1] + love.graphics.getHeight() - 400 + 50 * j - cam_y)
  end
  love.graphics.setColorMode("replace")
  love.graphics.draw(lovelogo, cam_n_x[1] + 20 - cam_x, cam_n_x[1] + love.graphics.getHeight() - 84 - cam_y)
  love.graphics.draw(cc, cam_n_x[1] + love.graphics.getWidth() - 100 - cam_x, cam_n_x[1] + love.graphics.getHeight() - 35 - cam_y)

  -- (2) New game
  love.graphics.setFont(menufont)
  love.graphics.print("New game", cam_n_x[2] + love.graphics.getWidth() / 2 - 100 - cam_x, cam_n_y[2] + 80 - cam_y)
  love.graphics.setFont(textfont)
  love.graphics.print("Enter your name:", cam_n_x[2] + 40 - cam_x, cam_n_y[2] + 200 - cam_y)
  love.graphics.setFont(menufont)
  if (love.timer.getTime() * 2) % 2 < 1 then
    love.graphics.print(name .. "_", cam_n_x[2] + 150 - cam_x, cam_n_y[2] + 350 - cam_y)
  else
    love.graphics.print(name, cam_n_x[2] + 150 - cam_x, cam_n_y[2] + 350 - cam_y)
  end
  love.graphics.setFont(textfont)
  love.graphics.print(name_error, cam_n_x[2] + 40 - cam_x, cam_n_y[2] + 450 - cam_y)

  -- (3) Load game
  love.graphics.setFont(menufont)
  love.graphics.print("Load game", cam_n_x[3] + love.graphics.getWidth() / 2 - 105 - cam_x, cam_n_y[3] + 80 - cam_y)
  love.graphics.setFont(textfont)
  love.graphics.print("Select user:", cam_n_x[3] + 40 - cam_x, cam_n_y[3] + 200 - cam_y)
  love.graphics.setFont(menufont)
  love.graphics.setColorMode("modulate")

  usrmen_min = math.max(-5, -lm_selected + 1)
  usrmen_max = math.min(5, lm_options - lm_selected)
  for j = usrmen_min, usrmen_max, 1 do
    if j == 0 then love.graphics.setColor(255, 255, 255, 255)
    else love.graphics.setColor(255, 255, 255, 127 - 21.25 * math.abs(j))
    end
    love.graphics.print(lm_option[lm_selected + j], cam_n_x[3] + love.graphics.getWidth() / 2 - 110 - cam_x, cam_n_y[3] + love.graphics.getHeight() / 2 + 50 + 50 * j - cam_y)
  end

  -- (4) Select level
  love.graphics.setColorMode("replace")
  love.graphics.setFont(menufont)
  love.graphics.print("Select level", cam_n_x[4] + love.graphics.getWidth() / 2 - 110 - cam_x, cam_n_y[4] + 80 - cam_y)
  love.graphics.setFont(textfont)
  --love.graphics.print("Select user:", cam_n_x[4] + 40 - cam_x, cam_n_y[3] + 200 - cam_y)
  --love.graphics.setFont(menufont)
  love.graphics.setColorMode("modulate")

  levmen_min = math.max(-5, -lev_selected + 1)
  levmen_max = math.min(5, uptolevel - lev_selected)
  for j = levmen_min, levmen_max, 1 do
    if j == 0 then love.graphics.setColor(255, 255, 255, 255)
    else love.graphics.setColor(255, 255, 255, 127 - 21.25 * math.abs(j))
    end
    love.graphics.print(lev_option[lev_selected + j], cam_n_x[4] + love.graphics.getWidth() / 2 - 260 - cam_x, cam_n_y[4] + love.graphics.getHeight() / 2 + 50 + 50 * j - cam_y)
    if lev_selected + j > 0 and lev_selected + j <= numlevels and besttime[lev_selected + j] ~= 0 then love.graphics.print(display_time(besttime[lev_selected + j]), cam_n_x[4] + love.graphics.getWidth() / 2 + 180 - cam_x, cam_n_y[4] + love.graphics.getHeight() / 2 + 50 + 50 * j - cam_y) end
  end

  -- (5) How to play, screen 1
  love.graphics.setColorMode("replace")
  love.graphics.setFont(menufont)
  love.graphics.print("How to play", cam_n_x[5] + love.graphics.getWidth() / 2 - 110 - cam_x, cam_n_y[5] + 80 - cam_y)
  love.graphics.setFont(textfont)
end

function change_menu(screen)
  if screen == 1 then mm_selected = 1
  elseif screen == 2 then
    name_table = {}
    name = ""
  elseif screen == 3 then
    lm_selected = 1
    lm_option = {}
    files = love.filesystem.enumerate("save")
    for i = 1, table.maxn(files), 1 do
      filematch = string.match(files[i], "^(.+)\.grvsv\.lua$")
      table.insert(lm_option, filematch)
    end
    lm_options = table.maxn(lm_option)
    lm_selected = 1
  elseif screen == 4 then
    refresh_levels()
  elseif screen == 6 then love.event.push("q")
  end

  menu_screen = screen
  cam_move_time = love.timer.getTime()
  cam_o_x = cam_x
  cam_o_y = cam_y
  change_dist = math.sqrt((cam_n_x[menu_screen] - cam_o_x)^2 + (cam_n_x[menu_screen] - cam_o_x)^2)
  firsthalf = true
  if change_dist ~= 0 then changescreen = true end
end

function refresh_saves()
  lm_option = {}
  files = love.filesystem.enumerate("save")
  for i = 1, table.maxn(files), 1 do
    filematch = string.match(files[i], "^(.+)\.grvsv\.lua$")
    table.insert(lm_option, filematch)
  end
  lm_options = table.maxn(lm_option)
  if lm_options == 0 then
    mm_options = 3
    mm_option[1] = "New game"
    mm_opt_val[1] = 2
    mm_option[2] = "How to play"
    mm_opt_val[2] = 5
    mm_option[3] = "Quit"
    mm_opt_val[3] = 6
  else
    mm_options = 4
    mm_option[1] = "New game"
    mm_opt_val[1] = 2
    mm_option[2] = "Load game"
    mm_opt_val[2] = 3
    mm_option[3] = "How to play"
    mm_opt_val[3] = 5
    mm_option[4] = "Quit"
    mm_opt_val[4] = 6
  end
end

function refresh_levels()
  uptolevel = numlevels + 1
  for i = 1, numlevels, 1 do
    if besttime[i] == 0 then
      uptolevel = i
      break
    end
  end
  lev_option = {}
  lev_options = uptolevel
  for i = 1, uptolevel, 1 do
    if i == numlevels + 1 then
      lev_option[i] = "Random level generator"
    else
      lev_option[i] = "Level " .. i .. ": " .. level_name[i]
    end
    lev_opt_val[i] = i
  end
  lev_selected = uptolevel
end
