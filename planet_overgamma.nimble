# Package

version       = "0.1.0"
author        = "liquid600pgm"
description   = "You crash on an irradiated, overgrown planet. Use modular " &
                "machines to find your way back home"
license       = "GPL-2.0"
srcDir        = "src"
bin           = @["planet_overgamma"]

# Dependencies

requires "nim >= 0.20.0"
requires "rapid"

import strutils
import os

const MaxCallStackDepth = 100

task run_debug, "Compile and run Planet Overgamma in debug mode":
  selfExec("c -r src/planet_overgamma " &
           "--debug.autostart --debug.overlay")

task snapshot, "Create a snapshot of the last compiled version":
  cpFile("src/planet_overgamma",
         "snapshots"/("planet_overgamma " & CompileDate & " " & CompileTime))
