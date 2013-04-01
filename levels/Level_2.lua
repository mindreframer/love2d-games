function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 0
  sm_pos_x = 512
  sm_pos_y = 150
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 4
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_pos_x[2] = 1000
  p_pos_y[2] = 350
  p_pos_x[3] = 1700
  p_pos_y[3] = 500
  p_pos_x[4] = 1900
  p_pos_y[4] = 1100
  p_rad[1] = 125
  p_rad[2] = 100
  p_rad[3] = 150
  p_rad[4] = 70
  p_density[1] = 1
  p_density[2] = 1
  p_density[3] = 1
  p_density[4] = 2
  p_ang[1] = 0
  p_ang[2] = 0
  p_ang[3] = math.pi/4
  p_ang[4] = -math.pi/2
  p_angv[1] = 0
  p_angv[2] = 0
  p_angv[3] = 0
  p_angv[4] = 0
  p_style[1] = 3
  p_style[2] = 2
  p_style[3] = 5
  p_style[4] = 1

  numparts = 4
  part_planet[1] = 1
  part_rel_lat[1] = math.pi/2
  part_planet[2] = 2
  part_rel_lat[2] = -math.pi/2
  part_planet[3] = 3
  part_rel_lat[3] = math.pi
  part_planet[4] = 0
  part_pos_x[4] = 1920
  part_pos_y[4] = 1280

  fuel = 0
  fuel_bottles = 0
end

function update_level(dt)
end
