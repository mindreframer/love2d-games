function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 0
  rel_lat = 0
  sm_pos_x = 512
  sm_pos_y = 0
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 1
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_rad[1] = 100
  p_density[1] = 1
  p_ang[1] = 0
  p_angv[1] = 0
  p_style[1] = 1

  numparts = 1
  part_planet[1] = 1
  part_rel_lat[1] = 0

  fuel = 0
  fuel_bottles = 0
end

function update_level(dt)
end
