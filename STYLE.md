# Planet Overgamma coding style

To ensure a consistent coding style across the codebase, these are the current
code style guidelines.

Use common sense when a specific code style decision is not listed here,
ie. look at the existing code to decide, or ask when contributing code via PRs.

## Whitespace

- 2 spaces for indentation
- max 80 columns (linted by luacheck)
- no spaces before prefix operators: `-a`, `#"hello"`
- put spaces around infix operators: `a + b`, `local a = b`
  - exception: `^` can be used without spaces: `a^2`
  - exception: `..` should always be used without spaces: `"example"..x`
    - exception: sometimes that's impossible next to number literals, eg.
      `x * 1000 .. " ms"`, then use spaces
- do not put spaces around dot `a.b` and colon `a:b()` operators
- no spaces before arguments in function definitions and calls:
  `function a(x, y) end`, `a(1, 2)`
  - exception: one space before function calls with a single string or table
    as a parameter: `require "mod"`, `ItemStorage:new { size = 32 }`
- always use a single space after a comma
- use `do..end` blocks whenever immediate mode-style code with `push()..pop()`
  functions is used. a good example of this is UI:
  ```lua
  ui:push("freeform", 800, 600) do
    -- do stuff
  end ui:pop()
  ```
  this helps better illustrate the structure constructed with push'n'pops.

## Naming

- all namespaces, variables, functions, and fields use `camelCase`
- all objects use `PascalCase`
- all modules use `kebab-case`
  - use dots `a.b` instead of slashes `a/b` in `require`
- for object fields:
  - if an object field clashes with a method, prefix it with an underscore
    `self._field`

## Globals

Never declare any globals. Using globals from the Lua standard library and
LÖVE is preferred over `require`.

## Strings

- use apostrophes for single-character strings: `'a'`
- use apostrophes for strings that contain quotes: `'example "hello"'`
- use long strings for… well, long strings:
    ```lua
    local text = [[
      Hello,
      world!
    ]]
  ```
- use quotes for all other strings: `"abc"`

## Function calls

- if a function accepts a single table parameter, use `func {}` syntax
- if a function is not a field and accepts a single string parameter, use
  `func "a"` syntax. do not use this syntax methods and namespaced functions,
  eg. `lib.func "a"`
- use the normal function call syntax everywhere else: `lib.func("a")`

## Functions

- put one space before the parameter list in anonymous functions:
  `print(function (a) end)`
- don't put any spaces before the parameter list in named functions:
  `local function abc(x) end`
- do not declare global functions
-
- always prefer `local function abc(x)` over `local abc = function (x)`
- prefer implicit `self` over explicitly naming the method receiver parameter
- use function declarations with a `.` if `self` is not used inside the
  function, and use `:` otherwise

## Documentation

Planet Overgamma currently does not have HTML documenation, but ideally every
public function should be documented using the following format.

- Each documentation comment starts with three dashes `---` followed by a space.
- Each documentation comment must be followed with a local variable, local
  function, or method.
  - exception: `@alias` directive, described below.
- The *brief* of the function is specified up until the first blank comment
  line, or the end of the comment.
- All other lines not starting with `@` are interpreted as the documentation
  body. The body is formatted with GitHub Flavored Markdown (GFM).
- Lines starting with `@` are interpreted as [EmmyLua][emmylua] directives.
  - Objects should be documented with the `@class` directive:
    ```lua
    --- @class Machine: Object
    local Machine = Object:inherit()
    ```
  - Simple tables that don't need a whole Object should use the `@alias`
    directive:
    ```lua
    --- @alias ItemStack { id: number, amount: number }
    ```
  - All method parameters and return values must have type annotations.
    ```lua
    --- Tries to remove the given amount of ore from the tile at the given position.
    --- Returns the ID of the ore, and the actual amount removed.
    ---
    --- @param position number
    --- @param amount number
    --- @return number oreID
    --- @return number amount
    function World:removeOre(position, amount)
      -- ...
    end
    ```
  - The complete behavior of varargs must be documented in the doc body, or
    at least have a brief description via a `@vararg` directive.
    ```lua
    --- Gets data for a control with the given ID.
    ---
    --- If `initFunc` is not nil, it's called with a freshly created data table to
    --- initialize the control data upon its creation.
    ---
    --- @param id any
    --- @param initFunc function | nil
    --- @vararg  Passed to initFunc alongside the data table.
    --- @return table
    function ControlData:get(id, initFunc, ...)
      -- ...
    end
    ```
  - Parameter, return type, and vararg descriptions should be separated from the
    name and type by 2 spaces.
  - The following additional directives may be used:
    - `@unsafe` - marks a function as unsafe for public use.

  [emmylua]: https://emmylua.github.io/index.html

## Checks

- prefer `if x == nil` or `if x ~= nil` over `if x` or `if not x`, as it states
  intent better and is less error-prone with booleans
  - exception: `assert(x, msg)` where `x` is a value that can be nil is allowed
    when the return value of the assertion is used. example:
    `local x = assert(c.x, "x must be provided")`

## `for` loops

- use `for k, v in pairs(x)` instead of `for k, v in next, x, nil`

## Module layout

Arrange all modules like this:

```lua
-- Module documentation goes here.

-- built-in requires go here
local bit = require "bit"

-- aliases for LÖVE namespaces go here
local lmath = love.math        -- use 'lmath' to not clash with Lua's 'math'
local graphics = love.graphics

-- own imports go here
local common = require "common"
local Object = require "object"

-- own aliases go here. may be split into multiple sections, apply common sense
local lerp = common.lerp
```

Always alias `love` namespaces, as it saves typing. Do this:

```lua
local graphics = love.graphics

local function drawStuff()
  graphics.push()
  -- …
  graphics.pop()
end
```

Don't do this:

```lua
local function drawStuff()
  love.graphics.push()
  -- …
  love.graphics.pop()
end
```

Never alias LÖVE namespaces to different names than their corresponding keys in
the `love` table. Don't do `local gfx = love.graphics`,
do `local graphics = love.graphics` instead.

Exception: explicit `love.` can be used if a LÖVE submodule is only used once
in a specific module.
