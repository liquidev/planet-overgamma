-- World interaction - breaking, placing, updating blocks,
-- dropping items, and other neat things that are a result of the player doing
-- stuff.

local bit = require "bit"

local band, bor = bit.band, bit.bor
local shl = bit.lshift

local common = require "common"
local game = require "game"
local Item = require "entities.item"
local items = require "items"
local Vec = require "vec"

local deg = common.degToRad

---

return function (World)

  local Chunk = World.Chunk

  -- A bitfield for specifying which faces a block is attached to.
  -- If a block receives an update and any of the specified faces is not solid,
  -- the block is broken.
  -- Faces can be combined using the + operator, eg.
  -- World.bottomFace + World.leftFace.
  World.topFace = 0x1
  World.bottomFace = 0x2
  World.leftFace = 0x4
  World.rightFace = 0x8

  -- Returns a bitfield of solid faces at the given position.
  local isSolid = World.isSolid
  function World:solidFaces(position)
    return
      bor(
        isSolid(self, position + Vec(0, -1)) and 0x1 or 0,
        isSolid(self, position + Vec(0,  1)) and 0x2 or 0,
        isSolid(self, position + Vec(-1, 0)) and 0x4 or 0,
        isSolid(self, position + Vec( 1, 0)) and 0x8 or 0
      )
  end

  -- Performs a block update at the specified position.
  -- Block updates can cause certain blocks to pop off. Blocks that pop off do
  -- not cause subsequent block updates.
  function World:updateBlock(position)
    local blockID = self:block(position)
    if blockID ~= World.air then
      local block = game.blocks[blockID]
      local solidFaces = self:solidFaces(position)
      local attachments = block.attachedTo or 0x0
      local connectedFaces = band(solidFaces, attachments)
      if connectedFaces ~= attachments then
        self:breakBlock(position, math.huge, false)
      end
    end
  end

  -- Finds a free position for spawning an item.
  local searchRadius = 7
  local function findFreeSpawnPosition(self, position)
    local tilePosition = (position / Chunk.tileSize):floor()

    -- kind of sucks
    if self:isSolid(tilePosition) then
      for r = 1, searchRadius do
        for oy = -r, r do
          for ox = -r, r do
            local free = tilePosition + Vec(ox, oy)
            if not self:isSolid(free) then
              position = self.unitPosition.center(free)
              return position
            end
          end
        end
      end
    end

    return position
  end

  -- Drops items centered at the given position according to the provided
  -- drop table.
  -- If the position is occupied, looks for free positions around the given
  -- position and spawns the item there.
  function World:dropItem(position, drop)
    position = findFreeSpawnPosition(self, position)
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
  -- updateBlocks can be set to destroy blocks without causing surrounding
  -- blocks to update.
  --
  -- If the destroyed block does not have a hardness value set explicitly,
  -- it is assumed to be 1.
  function World:breakBlock(position, charge, updateBlocks)
    charge = charge or math.huge
    if updateBlocks == nil then updateBlocks = true end

    local blockID = self:block(position)
    if blockID == World.air then return end

    local block = game.blocks[blockID]
    local hardness = block.hardness or 1
    if hardness < charge then
      local oreID = self:ore(position)
      local dropPosition = self.unitPosition.center(position)
      if oreID == World.noOre then
        self:setBlock(position, World.air)
        if block.drops ~= nil then
          self:dropItem(dropPosition, block.drops)
        end
      else
        local ore = game.ores[oreID]
        local _, minedAmount = self:removeOre(position, ore.item.amount)
        self:dropItem(dropPosition, items.drop(ore.item.id, minedAmount))
      end
      if updateBlocks then
        self:updateBlock(position + Vec(0, -1))
        self:updateBlock(position + Vec(0, 1))
        self:updateBlock(position + Vec(-1, 0))
        self:updateBlock(position + Vec(1, 0))
      end
      return block
    end
  end

  -- Places a tile at the provided position.
  -- tile can currently only be a block ID, but this will be expanded in the
  -- future.
  -- Returns whether the tile was successfully placed.
  function World:placeTile(position, tile)
    if not self:isEmpty(position) then return false end

    if type(tile) == "number" then
      self:setBlock(position, tile)
      self:updateBlock(position + Vec(0, -1))
      self:updateBlock(position + Vec(0, 1))
      self:updateBlock(position + Vec(-1, 0))
      self:updateBlock(position + Vec(1, 0))
    end
    return true
  end

end
