const
  MaxCallStackDepth = 200

switch("define", "nimCallDepthLimit=" & $MaxCallStackDepth)
switch("opt", "speed")
warning("LockLevel", off)
