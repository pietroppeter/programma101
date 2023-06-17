import nimib

nbInit

nbKaraxCode:
  var paper: seq[string]
  paper = @[
    "    3 M",
    "   25 A",
  ]

  import std / dom

  proc onKeyDown(event: Event) =
    echo event.`type`

  dom.window.addEventListener("keydown".cstring, onKeyDown)

  karaxHtml:
    for line in paper:
      pre:
        code:
          text $line
nbSave