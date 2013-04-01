function load_level(level)
  thislevel = level
  love.filesystem.load("levels/Level_" .. level .. ".lua")()
  init_level()
  for i = 1, numparts, 1 do
    part_visible[i] = true
  end
  init_level()	-- This is here twice deliberately
  level_loaded = true
  level_finished = false
  dead = false
  menu = false
  paused = false
  thispart = 1
  for i = 1, numplanets, 1 do
    p_mass[i] = 100 * p_density[i] * p_rad[i]^2
    p_oldpos_x[i] = 0
    p_oldpos_y[i] = 0
  end
  for i = 1, numparts, 1 do
    part_style[i] = math.random(3)
    part_ang[i] = 2 * math.pi * math.random()
  end
  for i = 1, fuel_bottles, 1 do
    fuel_remaining[i] = true
    fuel_ang[i] = 2 * math.pi * math.random()
  end
  level_start = love.timer.getTime()
end

function fix_angle(angle)
  while angle <= -math.pi do angle = angle + 2 * math.pi end
  while angle >   math.pi do angle = angle - 2 * math.pi end
  return angle
end

function drawbg()
  local a = 0
  local b = 0
  bgnum_x = math.ceil(love.graphics.getWidth()  / 1024)
  bgnum_y = math.ceil(love.graphics.getHeight() / 1024)
  bgcam_x = (cam_x / 2) % 1024
  bgcam_y = (cam_y / 2) % 1024
  for b = 0, bgnum_y, 1 do
    for a = 0, bgnum_x, 1 do
      love.graphics.draw(bg, math.ceil(-bgcam_x + a * 1024), math.ceil(-bgcam_y + b * 1024), 0, 1, 1)
    end
  end
end

function draw_arrow(t_x, t_y)
  t_dist = math.sqrt((t_x - cam_x - love.graphics.getWidth()/2)^2 + (t_y - cam_y - love.graphics.getHeight()/2)^2)
  t_ang = math.atan2(t_y - cam_y - love.graphics.getHeight()/2, t_x - cam_x - love.graphics.getWidth()/2)
  if t_dist > love.graphics.getHeight() / 2 then
    love.graphics.setColorMode("modulate")
    love.graphics.setColor(255 * math.exp(-(t_dist - love.graphics.getHeight()/2) / 8000), 0, 255 - 255 * math.exp(-(t_dist - love.graphics.getHeight()/2) / 5000), 127 - 127 * math.exp(-(t_dist - love.graphics.getHeight()/2) / 100))
    love.graphics.draw(arrow, love.graphics.getWidth()/2 + 300 * math.cos(t_ang), love.graphics.getHeight()/2  + 300 * math.sin(t_ang), t_ang + math.pi/2, 0.25, 0.25, 128, 128)
  end
end

function angle_diff(ang1, ang2)
  return math.min(math.abs(ang1 - ang2), math.abs(ang1 - ang2 + 2 * math.pi), math.abs(ang1 - ang2 - 2 * math.pi))
end

function new_savefile(uname)
  for i = 1, numlevels, 1 do
    besttime[i] = 0
  end
  uptolevel = 1
  return write_savefile(uname)
end

function write_savefile(uname)
  local savedata = "function get_saved_data()" .. string.char(10)
  for i = 1, numlevels, 1 do
    savedata = savedata .. "  besttime[" .. i .. "] = " .. besttime[i] .. string.char(10)
  end
  savedata = savedata .. "end"
  if love.filesystem.exists("save") == false then
    love.filesystem.mkdir("save")
  end
  return love.filesystem.write("save/" .. uname .. ".grvsv.lua", savedata)
end

function load_savefile(uname)
  name = uname
  love.filesystem.load("save/" .. uname .. ".grvsv.lua")()
  get_saved_data()
  uptolevel = 0
  for i = 1, numlevels, 1 do
    if besttime[i] == 0 then
      uptolevel = i
      break
    end
  end
end

function display_time(levtime)
  local minutes = math.floor(levtime / 60)
  local seconds = levtime % 60
  seconds = math.ceil(seconds * 100) / 100
  if seconds < 10 then seconds = "0" .. seconds end
  return minutes .. ":" .. seconds
end

function pad_zeros(num, digits)
  local j
  for j = 1, (digits - math.floor(math.log10(num)) - 1), 1 do
    num = "0" .. num
  end
  return num
end

function showvel(x1, y1, vx, vy)
  x2 = x1 + vx
  y2 = y1 + vy
  love.graphics.setColor(50, 50, 50, 255)
  love.graphics.line(x1, y1, x2, y1)
  love.graphics.line(x1, y1, x1, y2)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.line(x1, y1, x2, y2)
end

function showdir(x1, y1, ang)
  x2 = x1 + 200 * math.cos(ang)
  y2 = y1 + 200 * math.sin(ang)
  love.graphics.setColor(50, 50, 50, 255)
  love.graphics.line(x1, y1, x2, y1)
  love.graphics.line(x1, y1, x1, y2)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.line(x1, y1, x2, y2)
end
