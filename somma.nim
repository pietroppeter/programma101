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

  func `$`*(w: Word): string =
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
    echo p.memory[r], " ", r

  func zeroIfEmpty*(b: byte): byte =
    if b == Empty:
      return 0
    else:
      return b

  func isEmpty*(p: Perottina, r: Register, i: int): bool =
    p.memory[r][i] == Empty

  proc sum*(p: var Perottina) =
    # R = A + M
    # A = R
    p.reset R
    for i in countdown(23, 0):
      if p.isEmpty(R, i) and p.isEmpty(A, i) and p.isEmpty(M, i):
        break
      p.memory[R][i] = zeroIfempty(p.memory[R][i]) + zeroIfempty(p.memory[A][i]) + zeroIfEmpty(p.memory[M][i])
      if p.memory[R][i] > 9 and i > 0:
        p.memory[R][i - 1] = 1 
        p.memory[R][i] -= 10
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

  p.sum

  p.print A
  p.print R

nbSave