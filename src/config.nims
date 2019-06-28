const
  MaxCallStackDepth = 100

switch("define", "nimCallDepthLimit=" & $MaxCallStackDepth)
switch("opt", "speed")
warning("LockLevel", off)
