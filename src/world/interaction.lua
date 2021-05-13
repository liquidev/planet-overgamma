-- World interaction - breaking, placing, updating blocks,
-- dropping items, and other neat things that are a result of the player doing
-- stuff.

local common = require "common"
local game = require "game"
local Item = require "entities.item"
local items = require "items"

local deg = common.degToRad

---

return function (World)

  -- Drops items centered at the given position according to the provided
  -- drop table.
  function World:dropItem(position, drop)
    for _, stack in items.draw(drop) do
      local item = self:spawn(Item:new(self, stack))
        :randomizeVelocity(1, 1.25, deg(180+45), deg(270+45))
      item.body.position = position - item.body.size / 2
    end
  end

  -- Breaks the block at the provided position.
  -- This should be preferred if breaking-specific actions need to be taken,
  -- such as dropping items and updating surrounding blocks.
  --
  -- Upon successful destruction of a block, returns the block's metadata table.
  --
  -- charge can be used to limit which blocks can be broken. Any block with
  -- a hardness that's greater than charge will return nil instead of the
  -- block's metadata.
  -- By default, charge = math.huge.
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
      if block.drops ~= nil then
        self:dropItem(self.unitPosition.center(position), block.drops)
      end
      return block
    end
  end

end
