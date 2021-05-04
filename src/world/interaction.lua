-- World interaction - breaking, placing, updating blocks,
-- dropping items, and other neat things that are a result of the player doing
-- stuff.

local game = require "game"

---

return function (World)

  -- Breaks the block at the provided position.
  -- This should be preferred if breaking-specific actions need to be taken,
  -- such as dropping items and updating surrounding blocks.
  --
  -- Upon successful destruction of a block, returns the block's metadata table.
  --
  -- charge can be used to limit which blocks can be broken. Any block with
  -- a hardness that's greater than charge will return nil instead of the
  -- block's metadata.
  -- By default, charge is assumed to be math.huge.
  --
  -- If the destroyed block does not have a hardness value set explicitly,
  -- it is assumed to be 1.
  function World:breakBlock(position, charge)
    charge = charge or math.huge

    local blockID = self:block(position)
    if blockID == World.air then return end

    local block = game.blocks[blockID]
    local hardness = block.hardness or 1
    if hardness <= charge then
      self:block(position, World.air)
      return block
    end
  end

end
