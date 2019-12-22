/* overbase - the base of Planet Overgamma
   copyright (C) iLiquid, 2019 */

import ".api" for Mod
import ".res" for Sheet
import ".world/tiledb" for ItemDrop

var m = Mod["overbase"]

m.lang("data/lang")

m.block("plants", "data/blocks/plants.png", 2.0,
        [ItemDrop.one("overbase.plants")])
m.block("stone", "data/blocks/stone.png", 3.0,
        [ItemDrop.one("overbase.stone")])

m.decor("grass", "data/decor/grass.png", 0.1,
        [ItemDrop.minMax("overbase.plants", 0.2, 0.5)])
m.decor("pebbles", "data/decor/pebbles.png", 0.5,
        [ItemDrop.minMax("overbase.rock", 0.1, 0.3)])

