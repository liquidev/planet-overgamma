#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import glm

proc boxBlur*(radius: static[int]): array[radius, float] =
  for i in mitems(result):
    i = 1 / radius

proc conv*(arr: openarray[float], x: int, kernel: openarray[float]): float =
  # 1D convolution
  template get(n: int): float = arr[int(floorMod(n.float, arr.len.float))]
  result = 0.0
  let kernelCenter = int(kernel.len / 2)
  for n, f in kernel:
    result += get(x + (n - kernelCenter)) * f
