function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 3
  rel_lat = -math.pi/2
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 3
  p_rad[1] = 50
  p_density[1] = 1
  p_ang[1] = 0
  p_angv[1] = 12
  p_style[1] = 17
  p_rad[2] = 50
  p_density[2] = 1
  p_ang[2] = 0
  p_angv[2] = 12
  p_style[2] = 17
  p_pos_x[3] = 512
  p_pos_y[3] = 384
  p_rad[3] = 200
  p_density[3] = 1
  p_ang[3] = 0
  p_angv[3] = 0
  p_style[3] = 12

  numparts = 10
  part_planet[1] = 3
  part_rel_lat[1] = math.pi
  part_planet[2] = 3
  part_rel_lat[2] = 0
  part_planet[3] = 3
  part_rel_lat[3] = -1
  part_planet[4] = 3
  part_rel_lat[4] = 1.5
  part_planet[5] = 3
  part_rel_lat[5] = -2.5
  part_planet[6] = 0
  part_pos_x[6] = p_pos_x[3] + (p_rad[3] + 70) * math.cos(-1)
  part_pos_y[6] = p_pos_y[3] + (p_rad[3] + 70) * math.sin(-1)
  part_planet[7] = 0
  part_pos_x[7] = p_pos_x[3] + (p_rad[3] + 80) * math.cos(-3)
  part_pos_y[7] = p_pos_y[3] + (p_rad[3] + 80) * math.sin(-3)
  part_planet[8] = 0
  part_pos_x[8] = p_pos_x[3] + (p_rad[3] + 100) * math.cos(2)
  part_pos_y[8] = p_pos_y[3] + (p_rad[3] + 100) * math.sin(2)
  part_planet[9] = 0
  part_pos_x[9] = p_pos_x[3] + (p_rad[3] + 120) * math.cos(-math.pi)
  part_pos_y[9] = p_pos_y[3] + (p_rad[3] + 120) * math.sin(-math.pi)
  part_planet[10] = 0
  part_pos_x[10] = p_pos_x[3] + (p_rad[3] + 140) * math.cos(-1.5)
  part_pos_y[10] = p_pos_y[3] + (p_rad[3] + 140) * math.sin(-1.5)

  fuel = 0
  fuel_bottles = 0
end

function update_level(dt)
  p_pos_x[1] = p_pos_x[3] + 500 * math.sin(love.timer.getTime() - level_start) * math.cos(love.timer.getTime()/4 - level_start)
  p_pos_y[1] = p_pos_y[3] + 500 * math.sin(love.timer.getTime() - level_start) * math.sin(love.timer.getTime()/4 - level_start)
  p_pos_x[2] = p_pos_x[3] + 500 * math.sin(love.timer.getTime() - level_start + math.pi/2) * math.cos(love.timer.getTime()/4 - level_start + math.pi/2)
  p_pos_y[2] = p_pos_y[3] + 500 * math.sin(love.timer.getTime() - level_start + math.pi/2) * math.sin(love.timer.getTime()/4 - level_start + math.pi/2)
end
