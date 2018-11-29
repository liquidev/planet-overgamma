Inventory = {}
Inventory.__index = Inventory

function Inventory:new(o, limit, extra)
    o = o or {}
    setmetatable(o, self)
    self = o

    self.limit = limit or 4294967296

    extra = extra or {}
    self.items = {}
    for t, _ in pairs(Item.types) do
        self.items[t] = table.merge({
            amount = 0
        }, deepcopy(extra), true)
    end

    return self
end

function Inventory:has(...)
    local stacks = {...}
    local result = {}

    local result_all = true
    for _, s in pairs(stacks) do
        if self.items[s.id].amount >= s.amt then
            table.insert(result, true)
        break else
            table.insert(result, false)
            result_all = false
        end
    end
    table.insert(result, 1, result_all)

    return unpack(result)
end

function Inventory:spacefor(...)
    local stacks = {...}
    local result = {}

    local result_all = true
    for _, s in pairs(stacks) do
        if self.items[s.id].amount + s.amt > self.limit then
            table.insert(result, false)
            result_all = false
        break else
            table.insert(result, true)
        end
    end
    table.insert(result, 1, result_all)

    return unpack(result)
end

function Inventory:free(id)
    return self.limit - self.items[id].amount
end

function Inventory:consume(...)
    local stacks = {...}
    local result = {}

    local result_all = true
    for _, s in pairs(stacks) do
        if not (self:has(s)) then
            table.insert(result, false)
            result_all = false
        break else
            self.items[s.id].amount = self.items[s.id].amount - s.amt
            if self.onchange then self.onchange(self.items[s.id]) end
            table.insert(result, true)
        end
    end
    table.insert(result, 1, result_all)

    return unpack(result)
end

function Inventory:put(...)
    local stacks = {...}
    local result = {}

    local result_all = true
    for _, s in pairs(stacks) do
        if self.items[s.id].amount + s.amt > self.limit then
            table.insert(result, false)
            result_all = false
        break else
            self.items[s.id].amount = self.items[s.id].amount + s.amt
            if self.onchange then self.onchange(self.items[s.id]) end
            table.insert(result, true)
        end
    end
    table.insert(result, 1, result_all)

    return unpack(result)
end

function Inventory:consumeall(stack)
    local consumed = math.min(stack.amt, self.items[stack.id].amount)
    stack.amt = consumed

    self:consume(stack)

    return consumed
end
