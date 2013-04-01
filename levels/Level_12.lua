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

  numplanets = 11
  p_pos_x[1] = 512
  p_pos_y[1] = 384
  p_rad[1] = 100
  p_density[1] = 0
  p_ang[1] = 0
  p_angv[1] = 20
  p_style[1] = 13
  for i = 2, 10, 1 do
    p_pos_x[i] = p_pos_x[1] + 400 * math.cos((i - 3.5) * math.pi / 5)
    p_pos_y[i] = p_pos_y[1] + 400 * math.sin((i - 3.5) * math.pi / 5)
    p_rad[i] = 110
    p_density[i] = 0
    p_ang[i] = math.random() * 2 * math.pi - math.pi
    p_angv[i] = 12
    p_style[i] = 17
  end
  p_pos_x[11] = p_pos_x[1]
  p_pos_y[11] = p_pos_y[1] - 20000
  p_rad[11] = 400
  p_density[11] = 150
  p_ang[11] = 0
  p_angv[11] = 0
  p_style[11] = 12

  numparts = 10
  part_planet[1] = 0
  part_pos_x[1] = p_pos_x[1]
  part_pos_y[1] = 0
  part_planet[2] = 0
  part_pos_x[2] = p_pos_x[1] + 15
  part_pos_y[2] = -1000
  part_planet[3] = 0
  part_pos_x[3] = p_pos_x[1] - 15
  part_pos_y[3] = -2100
  part_planet[4] = 0
  part_pos_x[4] = p_pos_x[1] + 15
  part_pos_y[4] = -3300
  part_planet[5] = 0
  part_pos_x[5] = p_pos_x[1] - 15
  part_pos_y[5] = -4600
  part_planet[6] = 0
  part_pos_x[6] = p_pos_x[1] + 15
  part_pos_y[6] = -6200
  part_planet[7] = 0
  part_pos_x[7] = p_pos_x[1] - 15
  part_pos_y[7] = -8000
  part_planet[8] = 0
  part_pos_x[8] = p_pos_x[1] + 15
  part_pos_y[8] = -11000
  part_planet[9] = 0
  part_pos_x[9] = p_pos_x[1] - 15
  part_pos_y[9] = -14500
  part_planet[10] = 11
  part_rel_lat[10] = -math.pi/2

  fuel = 100
  fuel_bottles = 0
end

function update_level(dt)
end
