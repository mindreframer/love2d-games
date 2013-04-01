AutoCamerable = {
  getCameras = function()
    if(autoCamera~=nil) then return {autoCamera} end
    return {passion.graphics.defaultCamera}
  end
}
