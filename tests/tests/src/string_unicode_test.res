let suites: ref<Mt.pair_suites> = ref(list{})
let test_id = ref(0)
let eq = (loc, x, y) => {
  incr(test_id)
  suites :=
    list{
      (loc ++ (" id " ++ Js.Int.toString(test_id.contents)), _ => Mt.Eq(x, y)),
      ...suites.contents,
    }
}

let () = Js.log("你好")

let () = Js.log(`你好`)

let () = Js.log(%raw(`"你好"`))

let f = x =>
  switch x {
  | ' ' .. 'ÿ' => 0
  | 'ō' => 2
  | _ => 3
  }

let () = {
  eq(__LOC__, f('{'), 0)
  eq(__LOC__, f('ō'), 2)
  eq(__LOC__, f('Ƽ'), 3)
}
Mt.from_pair_suites(__FILE__, suites.contents)
