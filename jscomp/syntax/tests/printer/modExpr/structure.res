module StringArray = {
  type t = array<string>

  let empty = []
}

module Empty = {}

module Empty = {
  // TODO: convince management to implement this
}

module Empty = {/* test */}

module EmptyModule = {
  /* TODO: management on vacation */
}

module type T = {}

let g = {
  module M: T = {}
  0
}

module M7: {
  module N': {
    let x: int
  }
} = (M6: {
  module N: {
    let x: int
  }
  module N' = N
})


module M8 = M7

module M5 = G0()

module M7: {
  let x: int
} = {
  let x = 8
}

module M3: {
  module N': {
    let x: int
  }
} = {
  include M'
}

module G0: (X: {}) =>
{
  module N': {
    let x: int
  }
} = F0

module M6 = {
  module D = {
    let y = 3
  }
  module N = {
    let x = 1
  }
  module N' = N
}
