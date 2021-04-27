function love.conf(t)
  t.identity = "planet-overgamma"
  t.version = "11.3"

  t.window.title = "Planet Overgamma"
  t.window.width = 1024
  t.window.height = 768
  t.window.resizable = true
  t.window.minwidth = 1024
  t.window.minheight = 768

  t.modules.joystick = false
  t.modules.physics = false
  t.modules.thread = false
  t.modules.touch = false
end
