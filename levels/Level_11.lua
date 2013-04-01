function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 2
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

  numplanets = 8
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_rad[1] = 150
  p_density[1] = 1
  p_ang[1] = 0
  p_angv[1] = 12
  p_style[1] = 17
  p_pos_x[2] = p_pos_x[1] + 500 * math.cos(-4 * math.pi / 5)
  p_pos_y[2] = p_pos_y[1] + 500 * math.sin(-4 * math.pi / 5)
  p_rad[2] = 100
  p_density[2] = 1
  p_ang[2] = 0
  p_angv[2] = 0
  p_style[2] = 11
  p_pos_x[3] = p_pos_x[1] + 600 * math.cos(-2.2 * math.pi / 5)
  p_pos_y[3] = p_pos_y[1] + 600 * math.sin(-2.2 * math.pi / 5)
  p_rad[3] = 70
  p_density[3] = 1
  p_ang[3] = 0
  p_angv[3] = 0
  p_style[3] = 1
  p_pos_x[4] = p_pos_x[1] + 600 * math.cos(-0.7 * math.pi / 5)
  p_pos_y[4] = p_pos_y[1] + 600 * math.sin(-0.7 * math.pi / 5)
  p_rad[4] = 110
  p_density[4] = 1
  p_ang[4] = 0
  p_angv[4] = 0
  p_style[4] = 8
  p_pos_x[5] = p_pos_x[1] + 500 * math.cos(1 * math.pi / 5)
  p_pos_y[5] = p_pos_y[1] + 500 * math.sin(1 * math.pi / 5)
  p_rad[5] = 50
  p_density[5] = 1
  p_ang[5] = -2.5
  p_angv[5] = 0
  p_style[5] = 1
  p_pos_x[6] = p_pos_x[1] + 650 * math.cos(2.2 * math.pi / 5)
  p_pos_y[6] = p_pos_y[1] + 650 * math.sin(2.2 * math.pi / 5)
  p_rad[6] = 90
  p_density[6] = 1
  p_ang[6] = 0
  p_angv[6] = 0
  p_style[6] = 11
  p_pos_x[7] = p_pos_x[1] + 500 * math.cos(3.9 * math.pi / 5)
  p_pos_y[7] = p_pos_y[1] + 500 * math.sin(3.9 * math.pi / 5)
  p_rad[7] = 110
  p_density[7] = 1
  p_ang[7] = 0
  p_angv[7] = 0
  p_style[7] = 2
  p_rad[8] = 110
  p_density[8] = 1
  p_ang[8] = 0
  p_angv[8] = -1
  p_style[8] = 13

  numparts = 6
  part_planet[1] = 2
  part_rel_lat[1] = 1
  part_planet[2] = 5
  part_rel_lat[2] = -2
  part_planet[3] = 4
  part_rel_lat[3] = 2.5
  part_planet[4] = 7
  part_rel_lat[4] = 1
  part_planet[5] = 8
  part_rel_lat[5] = 2
  part_planet[6] = 4
  part_rel_lat[6] = 0.5

  fuel = 0
  fuel_bottles = 0
end

function update_level(dt)
  runtime = love.timer.getTime() - level_start
  p_pos_x[8] = p_pos_x[1] + 900 * math.cos(runtime / 2 - math.pi)
  p_pos_y[8] = p_pos_y[1] + 900 * math.sin(runtime / 2 - math.pi)
end
