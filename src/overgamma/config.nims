const
  MaxCallStackDepth = 200

switch("app", "gui")
switch("define", "nimCallDepthLimit=" & $MaxCallStackDepth)
#switch("opt", "speed")
warning("LockLevel", off)
