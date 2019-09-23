# Package

version       = "0.1.0"
author        = "liquid600pgm"
description   = "You crash on an irradiated, overgrown planet. Use modular " &
                "machines to find your way back home"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["planet_overgamma"]

# Dependencies

requires "nim >= 0.20.2"
requires "rapid"

proc initBuild() =
  if dirExists("build"):
    rmdir("build")
  mkdir("build")
  mkdir("build/data")

task runDebug, "Compile and run Planet Overgamma in debug mode":
  initBuild()
  selfExec("c -r -o:build/overgamma src/overgamma/overgamma " &
           "--debug.autostart --debug.showDrawTime " &
           "--debug.augment")

task snapshot, "Create a snapshot of the last compiled version":
  cpFile("src/planet_overgamma",
         "snapshots/planet_overgamma " & CompileDate & " " & CompileTime)
