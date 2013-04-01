##### inspired by:
## http://code.dimilow.com/git-subtree-notes-and-workflows/
# https://github.com/search?p=1&q=+L%C3%96VE&ref=commandbar&type=Repositories

PROJECTS = %w(
https://github.com/jotson/1gam-jan2013.git
https://github.com/jotson/1gam-feb2013.git
https://github.com/BlackBulletIV/ammo.git
https://github.com/GloryFish/BarcampRDU-2011-LuaLove.git
https://github.com/Cgg/CubeR.git
https://github.com/vrld/game-on.git
https://github.com/kikito/gamera.git
https://github.com/Middlerun/gravitonik.git
https://github.com/trubblegum/Gspot.git
https://github.com/greg-h/gunstar.git
https://github.com/jarednorman/hatred-skeleton.git
https://github.com/vrld/hump.git
https://github.com/quad/invader.love.git
https://github.com/centhra/ld25.git
https://github.com/minism/leaf.git
https://github.com/BlackBulletIV/love-builder.git
https://github.com/NikolaiResokav/LoveFrames.git
https://github.com/mandel59/lovesui.git
https://github.com/Stabyourself/mari0.git
https://github.com/kikito/pew-pew-boom.git
https://github.com/Moosader/Four-Languages.git
https://github.com/SimonLarsen/mrrescue.git
https://github.com/jdourlens/RasMoon.git
https://github.com/airolson/roguelove.git
https://github.com/SimonLarsen/sienna.git
https://github.com/Lafolie/Snakey.git
https://github.com/AngeloYazar/stable-fluids-lua.git
)

# https://github.com/SaxonDouglass/gauge.git -> a cool "alice in wonderland" game, a bit too big
# https://github.com/kikito/passion.git-- > strange checkout git bug...
JUNK = %w(
https://github.com/aurelien-defossez/soviet-vs-asteroids.git
https://github.com/tedajax/Ventix.git
https://github.com/Canti/Masai.git
https://github.com/mllyx/METALTEAR.git
https://github.com/martin-damien/SpaceStation512.git
https://github.com/Bellminator/Solis.git
https://github.com/oberonix/ColorBlaster.git
https://github.com/itoasterman/Chaos.git
https://github.com/FranciscoCanas/ActionMovie.git
https://github.com/hawkthorne/hawkthorne-journey.git
)
puts PROJECTS.sort_by{|x| x.split("/").last.downcase}.join("\n") ### to sort them
puts `du -sh *`

def remote_name(git_url)
  "remote_#{git_url.split("/").last[0..-5]}"
end

def name(git_url)
  git_url.split("/").last[0..-5]
end

def add_remote(git_url)
  cmd = "git remote add #{remote_name(git_url)} #{git_url}"
  `#{cmd}`
end

def add_project(git_url)
  cmd =  "git subtree add --prefix=#{name(git_url)} --squash #{git_url} master"
  `#{cmd}`
end

def update_project(git_url)
  cmd = "git subtree pull --prefix #{name(git_url)} --squash #{git_url} master"
  `#{cmd}`
end

def handle_project(git_url)
  if File.exist?(name(git_url))
    update_project(git_url)
  else
    add_remote(git_url)
    add_project(git_url)
  end
end

PROJECTS.each do |p| handle_project(p) end