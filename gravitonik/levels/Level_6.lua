function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 0
  sm_pos_x = 400
  sm_pos_y = -100
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 3
  p_pos_x[1] = 400
  p_pos_y[1] = 300
  p_rad[1] = 125
  p_rad[2] = 100
  p_rad[3] = 80
  p_density[1] = 1
  p_density[2] = 1
  p_density[3] = 1
  p_ang[1] = 0
  p_ang[2] = 0
  p_ang[3] = 0
  p_angv[1] = 0
  p_angv[2] = 1
  p_angv[3] = -1.5
  p_style[1] = 2
  p_style[2] = 3
  p_style[3] = 1

  numparts = 3
  part_planet[1] = 2
  part_rel_lat[1] = 0
  part_planet[2] = 0
  part_pos_x[2] = 0
  part_pos_y[2] = 0
  part_planet[3] = 3
  part_rel_lat[3] = 0

  fuel = 20
  fuel_bottles = 0
end

function update_level(dt)
  p_pos_x[2] = p_pos_x[1] + 800 * math.cos((love.timer.getTime() - level_start)/4)
  p_pos_y[2] = p_pos_y[1] - 800 * math.sin((love.timer.getTime() - level_start)/4)
  p_pos_x[3] = p_pos_x[2] + 300 * math.cos((love.timer.getTime() - level_start)/1.5)
  p_pos_y[3] = p_pos_y[2] + 300 * math.sin((love.timer.getTime() - level_start)/1.5)
end
