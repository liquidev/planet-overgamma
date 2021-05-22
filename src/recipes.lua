-- Recipe and storage-related utilities.

local game = require "game"

---

local recipes = {}

-- Returns whether the recipe can be crafted using the items from the provided
-- ItemStorage.
function recipes.canCraft(recipe, storage)
  for _, stack in ipairs(recipe.ingredients) do
    if storage:get(stack.id) < stack.amount then
      return false
    end
  end
  return true
end

-- Returns a table with recipes from the varargs-provided targets that can be
-- crafted using items from the provided ItemStorage.
function recipes.filter(storage, ...)
  local out = {}

  for i = 1, select('#', ...) do
    local target = select(i, ...)
    local targetRecipes = game.recipes[target]
    if targetRecipes ~= nil then
      for _, recipe in ipairs(targetRecipes) do
        if recipes.canCraft(recipe, storage) then
          table.insert(out, recipe)
        end
      end
    end
  end

  return out
end

-- Consumes the recipe's ingredients from the storage.
-- Returns whether the items were consumed. Note that if this returns false,
-- no items are consumed at all.
function recipes.consume(recipe, storage)
  if not recipes.canCraft(recipe, storage) then return false end

  for _, stack in ipairs(recipe.ingredients) do
    assert(storage:take(stack.id, stack.amount) == stack.amount)
  end
  return true
end

return recipes
