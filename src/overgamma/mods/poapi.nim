import tables

import euwren
import rapid/gfx/texpack
import rapid/res/images

import ../debug
import ../world/tiledb
import ../lang
import ../res
import moddef

proc wrenPO*(wren: Wren) =
  wren.foreign(".debug"):
    [Debug]:
      header do (msg: string): header(msg)
      error do (kind, msg: string): error(kind, msg)
      warn do (kind, msg: string): warn(kind, msg)
      info do (kind, msg: string): info(kind, msg)
      verbose do (kind, msg: string): verbose(kind, msg)
  wren.foreign(".lang"):
    [L]:
      `[]` do (key: string) -> string:
        result = L(key)
  wren.foreign(".world/tiledb"):
    ItemDropKind - id
    ItemDrop:
      *dropOne -> one
      *dropAmount -> amount
      *dropMinMax -> minMax
    TileDesc:
      *newTileDesc -> new
      ?kind
    TileDatabase:
      {.noFields.}
      addBlock do (db: TileDatabase, name: string, td: TileDesc):
        db.blocks[name] = td
      addDecor do (db: TileDatabase, name: string, td: TileDesc):
        db.decor[name] = td
      getBlock do (db: TileDatabase, name: string) -> TileDesc:
        result = db.blocks[name]
      getDecor do (db: TileDatabase, name: string) -> TileDesc:
        result = db.decor[name]
  wren.foreign(".res"):
    Sheet:
      *sheet -> `[]`
      ?texture
      `[]`(Sheet, string)
      `[]=`(Sheet, string, seq[RTextureRect])
      add(Sheet, RImage)
      """
      addGrid(image, tileWidth, tileHeight, rects) {
        var result = []
        for (pos in rects) {
          result.add(add(image.subimg(pos[0] * tileWidth, pos[1] * tileHeight,
                                      tileWidth, tileHeight)))
        }
        return result
      }
      """
    [Res]:
      ?tiles do -> TileDatabase: tiles
  wren.foreign(".api"):
    """
    import ".rapid/res/images" for RImage

    import ".debug" for Debug
    import ".lang" for L
    import ".res" for Res, Sheet
    import ".world/tiledb" for TileDesc
    """
    Mod:
      *`[]` do (name: string) -> Mod:
        result = mods[name]
      ?path
      ?codename
      ?name
      ?author
      ?version
      ?description
      lang do (m: Mod, dir: string):
        ## Load language strings from ``dir`` for the current language.
        loadLanguage(dir, m.codename)
      """
      block(name, tilesheetPath, hardness, drops) {
        var fullName = codename + "." + name
        Debug.verbose("Block", fullName + " <- " +
                               codename + ":" + tilesheetPath)
        var image = RImage.load(path + "/" + tilesheetPath)
        var variants = []
        var vw = image.width / 4
        var vh = image.height / 4
        Sheet[".blocks"][name] = Sheet[".blocks"].addGrid(image, vw, vh, [
          [3, 3], [0, 3], [2, 3], [1, 3],
          [3, 0], [0, 0], [2, 0], [1, 0],
          [3, 2], [0, 2], [2, 2], [1, 2],
          [3, 1], [0, 1], [2, 1], [1, 1]
        ])
        var tileDesc = TileDesc.new(name, L[codename + ".blocks " + name],
                                    hardness, drops)
        Res.tiles.addBlock(codename + "." + name, tileDesc)
      }
      decor(name, tilesheetPath, hardness, drops) {
        var fullName = codename + "." + name
        Debug.verbose("Decor", fullName + " <- " +
                               codename + ":" + tilesheetPath)
        var image = RImage.load(path + "/" + tilesheetPath)
        var variants = []
        var vw = image.height
        var vh = image.height
        var grid = []
        for (x in 0...image.width / vh) {
          grid.add([x, 0])
        }
        Sheet[".decor"][name] = Sheet[".decor"].addGrid(image, vw, vh, grid)
        var tileDesc = TileDesc.new(name, L[codename + ".decor " + name],
                                    hardness, drops)
        Res.tiles.addDecor(codename + "." + name, tileDesc)
      }
      """

