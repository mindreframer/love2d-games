function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 2
  rel_lat = 0
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 6
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_rad[1] = 200
  p_density[1] = 1
  p_ang[1] = 0
  p_angv[1] = 0
  p_style[1] = 10
  p_rad[2] = 70
  p_density[2] = 1
  p_ang[2] = 0
  p_angv[2] = -math.pi/4
  p_style[2] = 7
  p_rad[3] = 100
  p_density[3] = 1
  p_ang[3] = 0
  p_angv[3] = -math.pi/2
  p_style[3] = 3
  p_rad[4] = 50
  p_density[4] = 1
  p_ang[4] = -7 * math.pi/8
  p_angv[4] = 1
  p_style[4] = 1
  p_rad[5] = 80
  p_density[5] = 1
  p_ang[5] = 0
  p_angv[5] = math.pi
  p_style[5] = 4
  p_rad[6] = 130
  p_density[6] = 1
  p_ang[6] = 0
  p_angv[6] = math.pi/8
  p_style[6] = 2

  numparts = 4
  part_planet[1] = 3
  part_rel_lat[1] = 0
  part_planet[2] = 5
  part_rel_lat[2] = math.pi/2
  part_planet[3] = 6
  part_rel_lat[3] = 0
  part_planet[4] = 4
  part_rel_lat[4] = 0

  fuel = 0
  fuel_bottles = 2
  fuel_planet[1] = 4
  fuel_rel_lat[1] = 0
  fuel_planet[2] = 5
  fuel_rel_lat[2] = 0
end

function update_level(dt)
  runtime = love.timer.getTime() - level_start
  p_pos_x[2] = p_pos_x[1] + 600 * math.cos(runtime / 2 - math.pi)
  p_pos_y[2] = p_pos_y[1] + 600 * math.sin(runtime / 2 - math.pi)
  p_pos_x[3] = p_pos_x[1] + 1100 * math.cos(runtime / 4 - math.pi / 2)
  p_pos_y[3] = p_pos_y[1] + 1100 * math.sin(runtime / 4 - math.pi / 2)
  p_pos_x[4] = p_pos_x[3] - 300 * math.cos(runtime)
  p_pos_y[4] = p_pos_y[3] - 300 * math.sin(runtime)
  p_pos_x[5] = p_pos_x[1] + 1600 * math.cos(runtime / (4 * math.pi))
  p_pos_y[5] = p_pos_y[1] - 1600 * math.sin(runtime / (4 * math.pi))
  p_pos_x[6] = p_pos_x[1] + 1600 * math.cos(runtime / (4 * math.pi) + math.pi)
  p_pos_y[6] = p_pos_y[1] - 1600 * math.sin(runtime / (4 * math.pi) + math.pi)
end
