function init_level()
  cam_x = 0
  cam_y = 0

  thisplanet = 0
  rel_lat = 0
  sm_pos_x = 512
  sm_pos_y = 384
  sm_v_x = 0
  sm_v_y = 0
  sm_acc_x = 0
  sm_acc_y = 0
  sm_ang = 0
  sm_angv = 0
  sm_orient = 1

  numplanets = 6
  p_pos_x[1] = 10000
  p_pos_y[1] = 384
  p_rad[1] = 200
  p_density[1] = -5
  p_ang[1] = 0
  p_angv[1] = 0
  p_style[1] = 19
  for i = 1, 5, 1 do
    p_pos_x[i+1] = p_pos_x[1]
    p_pos_y[i+1] = p_pos_y[1]
    p_rad[i+1] = 200 - i * 35
    p_density[i+1] = 0
    p_ang[i+1] = 0
    p_angv[i+1] = 0
    p_style[i+1] = 25 - i
  end

  numparts = 1
  part_planet[1] = 1
  part_rel_lat[1] = 0
  part_visible[1] = false

  fuel = 100
  fuel_bottles = 0

  newpartplace = true
  ringsmoving = false
end

function update_level(dt)
  if newpartplace and thisplanet ~= 0 then findnewpartplace() end
end

function findnewpartplace()
  part_planet[thispart] = 1
  part_rel_lat[thispart] = -math.pi + math.random() * 2 * math.pi
  part_visible[thispart] = true
  
  newpartplace = false
end
