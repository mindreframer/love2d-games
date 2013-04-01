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

  numplanets = 1
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_rad[1] = 100
  p_density[1] = 1
  p_ang[1] = 0
  p_angv[1] = 0
  p_style[1] = 3

  numparts = 2
  part_planet[1] = 0
  part_pos_x[1] = 50000
  part_pos_y[1] = -50000
  part_planet[2] = 1
  part_rel_lat[2] = -math.pi/4

  fuel = 0
  fuel_bottles = 10
  fuel_planet[1] = 1
  fuel_rel_lat[1] = 1 * math.pi/10
  fuel_planet[2] = 1
  fuel_rel_lat[2] = 3 * math.pi/10
  fuel_planet[3] = 1
  fuel_rel_lat[3] = 5 * math.pi/10
  fuel_planet[4] = 1
  fuel_rel_lat[4] = 7 * math.pi/10
  fuel_planet[5] = 1
  fuel_rel_lat[5] = 9 * math.pi/10
  fuel_planet[6] = 0
  fuel_pos_x[6] = part_pos_x[1] + 100 * math.cos(-1 * math.pi/20)
  fuel_pos_y[6] = part_pos_y[1] + 100 * math.sin(-1 * math.pi/20)
  fuel_planet[7] = 0
  fuel_pos_x[7] = part_pos_x[1] + 100 * math.cos(-3 * math.pi/20)
  fuel_pos_y[7] = part_pos_y[1] + 100 * math.sin(-3 * math.pi/20)
  fuel_planet[8] = 0
  fuel_pos_x[8] = part_pos_x[1] + 100 * math.cos(-5 * math.pi/20)
  fuel_pos_y[8] = part_pos_y[1] + 100 * math.sin(-5 * math.pi/20)
  fuel_planet[9] = 0
  fuel_pos_x[9] = part_pos_x[1] + 100 * math.cos(-7 * math.pi/20)
  fuel_pos_y[9] = part_pos_y[1] + 100 * math.sin(-7 * math.pi/20)
  fuel_planet[10] = 0
  fuel_pos_x[10] = part_pos_x[1] + 100 * math.cos(-9 * math.pi/20)
  fuel_pos_y[10] = part_pos_y[1] + 100 * math.sin(-9 * math.pi/20)
end

function update_level(dt)
end
