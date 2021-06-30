std = "luajit+love"
ignore = {"212"}
max_line_length = 80
max_code_line_length = 80
max_string_line_length = 80
max_comment_line_length = 80


-- Disable linting in ext

files["src/ext"].only = {}

-- Extra globals from newer versions of LÖVE that luacheck doesn't seem to
-- support

local love = stds.love.read_globals.love.fields
local ro = { read_only = true }

love.math.fields.colorFromBytes = ro

