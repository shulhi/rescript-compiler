// Generated by ReScript, PLEASE EDIT WITH CARE


function Make(T) {
  return Q => {
    let Eq = E => (A => ({}));
    return {
      Eq: Eq
    };
  };
}

function Eq(E) {
  return A => ({});
}

let M = {
  Eq: Eq
};

let EQ = Eq({})({});

let MF = {
  F: funarg => (funarg => ({}))
};

function UseF(X) {
  return Y => MF.F(X)(Y);
}

export {
  Make,
  M,
  EQ,
  MF,
  UseF,
}
/* EQ Not a pure module */
