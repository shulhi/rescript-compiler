Console.log("ppx test")

type t = [#A | #B]

let a: t = #A
let b: t = #B

module M = {
  let v = 10
}

open M

let vv = v

module OptionalFields = {
  type opt = {x?: int, y: float}

  let r = {y: 1.0}
}

module Arity = {
  let one = x => x
  let two = (x, y) => x + y
  let n = two(one(1), 5)
}