import system except getCommand, setCommand, switch, `--`,
  packageName, version, author, description, license, srcDir, binDir, backend,
  skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, bin, foreignDeps,
  requires, task, packageName
import nimscriptapi, strutils
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

task runDebug, "Compile and run Planet Overgamma in debug mode":
  selfExec("c -r src/planet_overgamma " &
           "--debug.autostart --debug.showDrawTime " &
           "--debug.augment")

task snapshot, "Create a snapshot of the last compiled version":
  cpFile("src/planet_overgamma",
         "snapshots/planet_overgamma " & CompileDate & " " & CompileTime)

onExit()