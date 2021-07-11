-- Easing functions, for use with the tween module.
-- Functions that begin with 'p', such as pbounceOut, are parametric - they
-- are "factory" functions that return another function upon calling.
-- Default versions of these functions are provided with names without the
-- leading 'p'.

---

local easings = {}

-- This code is taken and adapted from pan:
-- https://github.com/liquidev/pan/blob/master/src/panpkg/assets/pan.lua#L433
-- which in turn uses easing functions from https://easings.net.
-- Refer to that website to see a preview of how all the easings look like!

function easings.linear(x) return x end

function easings.step(x, limit)
  if x > limit then return 1
  else return 0 end
end

local function inv(f)
  return function (x)
    return 1 - f(1 - x)
  end
end

function easings.sineIn(x) return 1 - math.cos((x * math.pi) / 2) end
function easings.sineOut(x) return math.sin((x * math.pi) / 2) end
function easings.sineInOut(x) return -(math.cos(math.pi * x) - 1) / 2 end

function easings.quadIn(x) return x * x end
easings.quadOut = inv(easings.quadIn)
function easings.quadInOut(x)
  if x < 0.5 then return 2 * x * x
  else return 1 - (-2 * x + 2)^2 / 2
  end
end

function easings.cubicIn(x) return x * x * x end
easings.cubicOut = inv(easings.cubicIn)
function easings.cubicInOut(x)
  if x < 0.5 then return 4 * x * x * x
  else return 1 - (-2 * x + 2)^3 / 2
  end
end

function easings.quarticIn(x) return x * x * x * x end
easings.quarticOut = inv(easings.quarticIn)
function easings.quarticInOut(x)
  if x < 0.5 then return 8 * x * x * x * x
  else return 1 - (-2 * x + 2)^4 / 2
  end
end

function easings.quinticIn(x) return x * x * x * x * x end
easings.quinticOut = inv(easings.quinticIn)
function easings.quinticInOut(x)
  if x < 0.5 then return 16 * x * x * x * x * x
  else return 1 - (-2 * x + 2)^5 / 2
  end
end

function easings.expoIn(x)
  if x == 0 then return 0
  else return 2^(10 * x - 10)
  end
end
easings.expoOut = inv(easings.expoIn)
function easings.expoInOut(x)
  if x == 0 then return 0
  elseif x == 1 then return 1
  else
    if x < 0.5 then return 2^(20 * x - 10) / 2
    else return (2 - 2^(-20 * x + 10)) / 2
    end
  end
end

function easings.circIn(x)
  return 1 - math.sqrt(1 - x * x)
end
easings.circOut = inv(easings.circIn)
function easings.circInOut(x)
  if x < 0.5 then return (1 - math.sqrt(1 - (2 * x)^2)) / 2
  else return (math.sqrt(1 - (-2 * x + 2)^2) + 1) / 2
  end
end

function easings.pbackOut(c1, c3)
  c1 = c1 or 1.70158
  c3 = c3 or c1 + 1
  return function (x)
    return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
  end
end
function easings.pbackIn(c1, c3)
  return inv(easings.pbackOut(c1, c3))
end
function easings.pbackInOut(c1, c2)
  c1 = c1 or 1.70158
  c2 = c2 or c1 * 1.525

  return function (x)
    if x < 0.5 then return ((2 * x)^2 * ((c2 + 1) * 2 * x - c2)) / 2
    else return ((2 * x - 2)^2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
  end
end

easings.backOut = easings.pbackOut()
easings.backIn = easings.pbackIn()
easings.backInOut = easings.pbackInOut()

function easings.pelasticIn(c4)
  c4 = c4 or (2 * math.pi) / 3

  return function (x)
    if x == 0 then return 0
    elseif x == 1 then return 1
    else return -2^(10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
    end
  end
end
function easings.pelasticOut(c4)
  return inv(easings.pelasticIn(c4))
end
function easings.pelasticInOut(c5)
  c5 = c5 or (2 * math.pi) / 4.5

  return function (x)
    if x == 0 then return 0
    elseif x == 1 then return 1
    else
      if x < 0.5 then
        return -(2^(20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
      else
        return (2^(-20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
      end
    end
  end
end

easings.elasticIn = easings.pelasticIn()
easings.elasticOut = easings.pelasticOut()
easings.elasticInOut = easings.pelasticInOut()

function easings.pbounceOut(n1, d1)
  n1 = n1 or 7.5625
  d1 = d1 or 2.75

  return function (x)
    if x < 1 / d1 then
      return n1 * x * x
    elseif x < 2 / d1 then
      x = x - 1.5 / d1
      return n1 * x * x + 0.75
    elseif x < 2.5 / d1 then
      x = x - 2.25 / d1
      return n1 * x * x + 0.9375
    else
      x = x - 2.625 / d1
      return n1 * x * x + 0.984375
    end
  end
end
function easings.pbounceIn(n1, d1)
  return inv(easings.pbounceOut(n1, d1))
end
function easings.pbounceInOut(n1, d1)
  local bounceOut = easings.pbounceOut(n1, d1)
  return function (x)
    if x < 0.5 then return (1 - bounceOut(1 - 2 * x)) / 2
    else return (1 + bounceOut(2 * x - 1)) / 2
    end
  end
end

easings.bounceOut = easings.pbounceOut()
easings.bounceIn = easings.pbounceIn()
easings.bounceInOut = easings.pbounceInOut()

return easings

