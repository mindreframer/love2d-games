function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 1
  rel_lat = -math.pi/2
  sm_pos_x = 512
  sm_pos_y = 0
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 2
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_pos_x[2] = 3500
  p_pos_y[2] = 384
  p_rad[1] = 100
  p_rad[2] = 200
  p_density[1] = 1.5
  p_density[2] = 0.75
  p_ang[1] = 0
  p_ang[2] = 0
  p_angv[1] = 0
  p_angv[2] = 1
  p_style[1] = 1
  p_style[1] = 4

  numparts = 5
  part_planet[1] = 0
  part_pos_x[1] = p_pos_x[2] + 300 * math.cos(0)
  part_pos_y[1] = p_pos_y[2] + 300 * math.sin(0)
  part_planet[2] = 0
  part_pos_x[2] = p_pos_x[2] + 300 * math.cos(math.pi/2)
  part_pos_y[2] = p_pos_y[2] + 300 * math.sin(math.pi/2)
  part_planet[3] = 0
  part_pos_x[3] = p_pos_x[2] + 300 * math.cos(math.pi)
  part_pos_y[3] = p_pos_y[2] + 300 * math.sin(math.pi)
  part_planet[4] = 0
  part_pos_x[4] = p_pos_x[2] + 300 * math.cos(-math.pi/2)
  part_pos_y[4] = p_pos_y[2] + 300 * math.sin(-math.pi/2)
  part_planet[5] = 1
  part_rel_lat[5] = math.pi

  fuel = 0
  fuel_bottles = 1
  fuel_planet[1] = 1
  fuel_rel_lat[1] = math.pi/2
end

function update_level(dt)
end
