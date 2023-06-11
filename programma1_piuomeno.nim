import nimib

nbInit

nbText: """ # "più o meno"

I want to implement step by step an emulator for programma 101.

In this first installement I will:
- set as a target a very simple program that adds two integer numbers
- decide on some basic types to represent internal state of the computer
- implement addition and maybe also substraction

Expression "più o meno" in Italian means "more or less" but also "plus or minus".
I have more or less understood how Programma 101 works in its basic form but I still
miss some parts.

## A simple calculation

Here is a simple commented program that is what we want to target.
I am writing as it would be written in P101 Manual (it is indeed the first example on page 4)
and in a way that is valid nim syntax:
"""
nbCode:
  import macros

  dumpTree:
    25 ⬇️  # set 25 in register M and move it in register A (this prints "25 M⬇️" to tape, the M is implicit)
    10 ➖  # set 10 in register M and perform subtraction A - M and put result in A  (this prints "10 M➖" to tape, the M is implicit)
    A  🔶  # print content of register A (prints "15 A🔶" on tape)
nbText: """
- I am using emojis since using an operator will get me an indentation error
  (nim expects + and - to be binary operators and does not like a new line after them)
- I want to be able to do the same operation with the sum

## A simple architecture

In order to perform the above computation I will need to be able to:
- set a number in memory in register M
- move a number from register M to register A
- perform addition or subtraction between two registers and set the result in register A
- get a result from a register (A in this case)

The memory of Programma 101 consists of:
- 10 registers M, A, R, B, C, D, E, F, P1 and P2
  - M is the working memory and second operand in operations
  - A is used for first operand and final result of an operation
  - R is a "remainder" register also used for "complete" results (without truncation)
  - B, C, D, E and F are generic data registers (we can access half registers and some of them can be used for program data)
  - P1 and P2 are dedicated to program data
- each register is made of 24 bytes
- there is a Decimal Limit Wheel that can go from 0 to 15 and tells how many decimals to keep in the result of operations
  (and how many decimal numbers to display)
The memory thus consists of a total of 1920 bits.
A curious fact is that it is implemented in hardware as a [magnetostrictive delay-line](https://en.wikipedia.org/wiki/Delay-line_memory#Magnetostrictive_delay_lines).

I can encode this information in the following types:
"""
nbCode:
  type
    Byte* = uint8
    Word* = array[24, Byte]
    Register* = enum
      M, A, R, B, C, D, E, F, P1, P2
    Perottina* = object
      memory*: array[Register, Word]
      decimalLimit*: range[0 .. 15]
nbText: """
- note that the memory array is indexed by an `enum`
- I am using the internal name "Perottina" used at Olivetti (from the father of Programma 101 Pier Giorgio Perotto)
  for the internal type that represents the state of the machine

Now to set an integer number in a register I need to know that numbers are stored as
as [Binary-coded decimals](https://en.wikipedia.org/wiki/Binary-coded_decimal)
and the 24 bytes are used to encode information about 22 decimal digits plus the sign and the comma position.

From what I understand register are big endian (most significant index first)
and the last 22 bytes are used to store the digit.
"""
nbCode:
  var p = Perottina()

  type
    Digit* = range[0 .. 9]

  proc push*(w: var Word, digit: Digit) =
    for i in 2 .. 22:
      w[i] = w[i+1]  # shift left
    w[23] = digit.uint8

  proc push*(p: var Perottina, d: Digit) =
    p.memory[M].push(d)

  func `$`*(w: Word): string =
    for i in 2 .. 23:
      if w[i] > 0 or result.len > 0:
        result.add $w[i]

  p.push 2
  p.push 5
  echo $p.memory[M]

  proc pushDown*(p: var Perottina) =
    p.memory[A] = p.memory[M]

  proc reset*(p: var Perottina, r: Register) =
    for i in 0 .. 23:
      p.memory[r][i] = 0

  p.reset M
  p.push 1
  p.push 0
  echo $p.memory[M]

nbSave