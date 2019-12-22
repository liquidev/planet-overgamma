/* overbase - the base of Planet Overgamma
   copyright (C) iLiquid, 2019 */

import ".api" for Mod
import ".res" for Sheet
import ".world/tiledb" for ItemDrop

var m = Mod["overbase"]

/* language */

m.lang("data/lang")

/* items */

m.item("plantMatter", "data/items/plantMatter.png")
m.item("rocks", "data/items/rocks.png")

/* tiles */

m.block("plants", "data/blocks/plants.png", 2.0,
        [ItemDrop.one("overbase.plantMatter")])
m.block("stone", "data/blocks/stone.png", 3.0,
        [ItemDrop.one("overbase.rocks")])

m.decor("grass", "data/decor/grass.png", 0.1,
        [ItemDrop.minMax("overbase.plantMatter", 0.2, 0.5)])
m.decor("pebbles", "data/decor/pebbles.png", 0.5,
        [ItemDrop.minMax("overbase.rocks", 0.1, 0.3)])

