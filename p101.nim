type
  Reg* = array[24, byte]
  RegLabel* = enum
    M, A, R, B, C, D, E, F, P1, P2
  Digit* = range[0 .. 9]
  Perottina* = object
    memory*: array[RegLabel, Reg]

const
  Empty* = ord(' ').byte

proc push*(w: var Reg, b: byte) =
  for i in 0 ..< w.high:
    w[i] = w[i+1]  # shift left
  w[w.high] = b

proc push*(p: var Perottina, d: Digit) =
  p.memory[M].push(d.byte)

proc pushMinus*(p: var Perottina) =
  p.memory[M].push('-'.byte)

func toString*(w: Reg): string =
  for i in 0 .. w.high:
    if w[i] <= Digit.high.byte:
      result.add $w[i]
    else:
      result.add $(char(w[i]))

proc pushDown*(p: var Perottina) =
  p.memory[A] = p.memory[M]

proc reset*(p: var Perottina, r: RegLabel) =
  for i in 0 .. 23:
    p.memory[r][i] = Empty

proc print*(p: Perottina, r: RegLabel) =
  echo p.memory[r].toString, " ", r

func zeroIfEmpty*(b: byte): byte =
  if b == Empty:
    return 0
  else:
    return b

type
  OpAtom* = tuple[reg: Reg, bit: byte]

func divmod10*(b: byte): (byte, byte) =
  result = (b mod 10, b div 10)

func sum10*(a, b, c: byte): (byte, byte) =
  divmod10(a + b + c)

func comp9*(b, c: byte): (byte, byte) =
  divmod10(9 - b + c)

func comp9*(w: Reg, c: byte): Reg =
  var c = c
  for i in countdown(23, 0):
    (result[i], c) = comp9(zeroIfEmpty(w[i]), c)

func isEmpty*(p: Perottina, r: RegLabel, i: int): bool =
  p.memory[r][i] == Empty

func normalize*(w: var Reg) =
  if w[0] == 0:
    var i = 0
    while w[i] == 0 and i < 23:
      w[i] = Empty
      inc i
  elif w[0] == 9:
    var i = 0
    while w[i] == 9 and i < 23:
      w[i] = Empty
      inc i
    w[i - 1] = '-'.byte
    while i < 23:
      w[i] = 9 - w[i]
      inc i

func denormalize*(r: var Reg) =
  var doComp9 = false
  for i in 0 .. 23:
    if r[i] == '-'.byte:
      doComp9 = true
      r[i] = 0
    else:
      r[i] = zeroIfEmpty(r[i])
  if doComp9:
    r = comp9(r, 1)

proc sum*(r: var Reg, a: Reg) =
  var carry = 0.byte
  for i in countdown(23, 0):
    (r[i], carry) = sum10(r[i], a[i], carry)

proc sum*(p: var Perottina) =
  ## A + M
  # R = M
  # R = A + R
  # A = R
  p.memory[R] = p.memory[M]
  denormalize p.memory[R]
  denormalize p.memory[A]
  sum(p.memory[R], p.memory[A])
  normalize p.memory[R]
  p.memory[A] = p.memory[R]

proc difference*(p: var Perottina) =
  ## A - M
  # R = comp9 M
  # R = A + R
  p.memory[R] = p.memory[M]
  denormalize p.memory[R]
  p.memory[R] = comp9(p.memory[R], 1)
  denormalize p.memory[A]
  sum(p.memory[R], p.memory[A])
  normalize p.memory[R]
  p.memory[A] = p.memory[R]

when isMainModule:
  import strutils

  var p = Perottina()

  template printMAR =
    p.print M
    p.print A
    p.print R

  template checkMAR(m, a, r: int) =
    doAssert p.memory[M].toString.strip == $m
    doAssert p.memory[A].toString.strip == $a
    doAssert p.memory[R].toString.strip == $r

  echo "22 + 3 = 25"
  p.reset M
  p.push 2
  p.push 2
  p.pushDown
  p.reset M
  p.push 3
  p.sum
  printMAR
  checkMAR 3, 25, 25

  echo "10 - 25 = -15"
  p.reset M
  p.push 1
  p.push 0
  p.pushDown
  p.reset M
  p.push 2
  p.push 5
  p.difference
  printMAR
  checkMAR 25, -15, -15

  echo "-25 - 10 = -35"
  p.reset M
  p.pushMinus
  p.push 2
  p.push 5
  p.pushDown
  p.reset M
  p.push 1
  p.push 0
  p.difference
  printMAR
  checkMAR 10, -35, -35

  echo "-25 - -10 = -15"
  p.reset M
  p.pushMinus
  p.push 2
  p.push 5
  p.pushDown
  p.reset M
  p.pushMinus
  p.push 1
  p.push 0
  p.difference
  printMAR
  checkMAR -10, -15, -15
