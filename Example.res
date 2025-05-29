type rec expression =
  | /** non-negative integer constant */ Numeral(float)
  | /** Addition [e1 + e2] */ Plus(expression, expression)

/** doc comment */

// comment
let a = 1
