import nimib, p5

nbInit
nbUseP5
nbText: """
Interface of p101 using p5nim:
- 0 .. 9: push digit in register M
- n: push - (negative sign) in register M
- w: reset register M
- v: push down (transfer from register M to register A), also prints M
- +: sum A + M, also prints M and result A
- -: difference A - M, also prints M and result A
"""
nbJsFromCode:
  import strutils
  var lastKey: char

  import p101

  var p = Perottina()
  var paper: seq[string]

  p.reset M
  p.reset A
  p.reset R

  setup:
    createCanvas(500, 500)
    background(200)

  draw:
    background(200)
    var y = 20
    for line in paper:
      text(line, 20, y)
      y += 20
    
    text("lastKey: " & $lastKey, 300, 20)
    text("      M: " & $(p.get M), 300, 40)
    text("      A: " & $(p.get A), 300, 60)
    text("      R: " & $(p.get R), 300, 80)

  keyPressed:
    lastKey = ($key)[0]
    case lastKey
    of '0' .. '9':
      p.push ord(lastKey) - ord('0')
    of 'v':
      p.pushDown
      paper.add (p.get M) & " ⬇️M"
    of 'w':
      p.reset M
    of '+':
      p.sum
      paper.add (p.get M) & " +"
      paper.add (p.get A) & " A"
    of 'n':
      p.pushMinus
    of '-':
      p.difference
      paper.add (p.get M) & " -"
      paper.add (p.get A) & " A"
    else:
      discard

nbSave