import ".world/tile" for Tile, TileBehavior, TileKind

class GroundDecor is TileBehavior {
  update(world, x, y) {
    if (world[x, y - 1].kind == TileKind.Void) {
      world[x, y] = Tile.void()
    }
  }
}

