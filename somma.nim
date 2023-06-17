import nimib

nbInit
nbText: "somma"
nbCode:
  type
    Word* = array[24, byte]
    Register* = enum
      M, A, R, B, C, D, E, F, P1, P2
    Digit* = range[0 .. 9]
    Perottina* = object
      memory*: array[Register, Word]

  const
    Empty* = ord(' ').byte


  proc push*(w: var Word, digit: Digit) =
    for i in 0 ..< w.high:
      w[i] = w[i+1]  # shift left
    w[w.high] = digit.uint8

  proc push*(p: var Perottina, d: Digit) =
    p.memory[M].push(d)

  func toString*(w: Word): string =
    for i in 0 .. w.high:
      if w[i] <= Digit.high.byte:
        result.add $w[i]
      else:
        result.add $(char(w[i]))

  proc pushDown*(p: var Perottina) =
    p.memory[A] = p.memory[M]

  proc reset*(p: var Perottina, r: Register) =
    for i in 0 .. 23:
      p.memory[r][i] = Empty

  proc print*(p: Perottina, r: Register) =
    echo p.memory[r].toString, " ", r

  func zeroIfEmpty*(b: byte): byte =
    if b == Empty:
      return 0
    else:
      return b

  type
    OpAtom* = tuple[reg: Word, bit: byte]

  func divmod10*(b: byte): (byte, byte) =
    result = (b mod 10, b div 10)

  func sum10*(a, b, c: byte): (byte, byte) =
    divmod10(a + b + c)

  func comp9*(b, c: byte): (byte, byte) =
    divmod10(9 - b + c)

  func comp9*(w: Word, c: byte): Word =
    var c = c
    for i in countdown(23, 0):
      (result[i], c) = comp9(zeroIfEmpty(w[i]), c)

  func isEmpty*(p: Perottina, r: Register, i: int): bool =
    p.memory[r][i] == Empty

  proc sum*(p: var Perottina) =
    ## A + M
    # R = M
    # R = A + R
    # A = R
    p.memory[R] = p.memory[M]
    var carry = 0.byte
    for i in countdown(23, 0):
      if p.isEmpty(R, i) and p.isEmpty(A, i):
        break
      (p.memory[R][i], carry) = sum10(zeroIfempty(p.memory[R][i]), zeroIfempty(p.memory[A][i]), carry)
    p.memory[A] = p.memory[R]

  func normalize*(w: var Word) =
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
      #inc w[i]

  proc difference*(p: var Perottina) =
    ## A - M
    # R = comp9 M
    # R = A + R
    var carry = 0.byte
    p.memory[R] = comp9(p.memory[M], 1)
    for i in countdown(23, 0):
      if p.isEmpty(R, i) and p.isEmpty(A, i):
        break
      (p.memory[R][i], carry) = sum10(zeroIfempty(p.memory[R][i]), zeroIfempty(p.memory[A][i]), carry)
    normalize p.memory[R]
    p.memory[A] = p.memory[R]

  var p = Perottina()

  p.reset M
  p.push 2
  p.push 5
  p.pushDown
  p.reset M
  p.push 1
  p.push 8
  p.push 7

  p.print M
  p.print A

  echo "A + M"
  p.sum
  p.print M
  p.print A
  p.print R

  p.difference
  echo "A - M"

  p.print M
  p.print A
  p.print R

  echo "10 - 25"
  p.reset A
  p.reset R
  p.reset M

  p.push 1
  p.push 0
  p.pushDown
  p.reset M
  p.push 2
  p.push 5
  p.difference

  p.print M
  p.print A
  p.print R
  p.print A

  echo "9 - 9"
  p.reset A
  p.reset R
  p.reset M
  p.push 9
  p.pushDown
  p.difference
  p.print A



nbSave