function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 1
  rel_lat = -math.pi/2
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 3
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_pos_x[2] = 900
  p_pos_y[2] = 100
  p_pos_x[3] = 300
  p_pos_y[3] = -100
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
  p_angv[2] = 0
  p_angv[3] = 0
  p_style[1] = 2
  p_style[2] = 3
  p_style[3] = 1

  numparts = 3
  part_planet[1] = 1
  part_rel_lat[1] = math.pi/2
  part_planet[2] = 2
  part_rel_lat[2] = 0
  part_planet[3] = 3
  part_rel_lat[3] = math.pi

  fuel = 0
  fuel_bottles = 0
end

function update_level(dt)
end
