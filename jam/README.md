# lovejam

A fast engine for Love2D built for game jams.

The engine was initially built for Open Jam 2018 submission "[Spamality!](https://github.com/liquid600pgm/spamality)",
but is now treated as a separate project.

## Features

 - Automatic asset management
 - Map support with editor
 - Built in entity collision detection
 - Base classes for certain genres of games:
   - Shooter
   - Platformer

## Installation

### Creating new projects

Open Bash and type in the following command:

```sh
$ git submodule add https://github.com/liquid600pgm/lovejam
```

Then in your `main.lua` add this to the beginning:

```lua
require 'jam'
```

### Contributing to existing lovejam projects

Open Bash and type in the following commands:

```sh
$ git submodule update --init --recursive
```

## Credits

 - [Love2D](https://love2d.org/)
 - [lua-struct](https://github.com/iryont/lua-struct)
