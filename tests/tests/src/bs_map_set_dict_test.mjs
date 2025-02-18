// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Mt from "./mt.mjs";
import * as Belt_Id from "rescript/lib/es6/Belt_Id.js";
import * as Belt_Map from "rescript/lib/es6/Belt_Map.js";
import * as Belt_Set from "rescript/lib/es6/Belt_Set.js";
import * as Belt_List from "rescript/lib/es6/Belt_List.js";
import * as Belt_Array from "rescript/lib/es6/Belt_Array.js";
import * as Belt_MapDict from "rescript/lib/es6/Belt_MapDict.js";
import * as Belt_SetDict from "rescript/lib/es6/Belt_SetDict.js";
import * as Primitive_int from "rescript/lib/es6/Primitive_int.js";
import * as Array_data_util from "./array_data_util.mjs";

let suites = {
  contents: /* [] */0
};

let test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function b(loc, v) {
  Mt.bool_suites(test_id, suites, loc, v);
}

let Icmp = Belt_Id.comparable(Primitive_int.compare);

let Icmp2 = Belt_Id.comparable(Primitive_int.compare);

let Ic3 = Belt_Id.comparable(Primitive_int.compare);

let m0 = Belt_Map.make(Icmp);

let m00 = Belt_Set.make(Ic3);

let I2 = Belt_Id.comparable((x, y) => Primitive_int.compare(y, x));

let m = Belt_Map.make(Icmp2);

let m2 = Belt_Map.make(I2);

let data = Belt_Map.getData(m);

Belt_Map.getId(m2);

let m_dict = Belt_Map.getId(m);

for (let i = 0; i <= 100000; ++i) {
  data = Belt_MapDict.set(data, i, i, m_dict.cmp);
}

let newm = Belt_Map.packIdData(m_dict, data);

console.log(newm);

let m11 = Belt_MapDict.set(undefined, 1, 1, Icmp.cmp);

Belt_Map.make(Icmp);

console.log(m11);

let v = Belt_Set.make(Icmp2);

let m_dict$1 = Belt_Map.getId(m);

let cmp = m_dict$1.cmp;

let data$1 = Belt_Set.getData(v);

for (let i$1 = 0; i$1 <= 100000; ++i$1) {
  data$1 = Belt_SetDict.add(data$1, i$1, cmp);
}

console.log(data$1);

function f(none) {
  return Belt_Map.fromArray(none, Icmp);
}

function $eq$tilde(a, b) {
  return extra => Belt_Map.eq(a, b, extra);
}

let u0 = Belt_Map.fromArray(Belt_Array.map(Array_data_util.randomRange(0, 39), x => [
  x,
  x
]), Icmp);

let u1 = Belt_Map.set(u0, 39, 120);

b("File \"bs_map_set_dict_test.res\", line 72, characters 4-11", Belt_Array.every2(Belt_Map.toArray(u0), Belt_Array.map(Array_data_util.range(0, 39), x => [
  x,
  x
]), (param, param$1) => {
  if (param[0] === param$1[0]) {
    return param[1] === param$1[1];
  } else {
    return false;
  }
}));

b("File \"bs_map_set_dict_test.res\", line 79, characters 4-11", Belt_List.every2(Belt_Map.toList(u0), Belt_List.fromArray(Belt_Array.map(Array_data_util.range(0, 39), x => [
  x,
  x
])), (param, param$1) => {
  if (param[0] === param$1[0]) {
    return param[1] === param$1[1];
  } else {
    return false;
  }
}));

eq("File \"bs_map_set_dict_test.res\", line 84, characters 5-12", Belt_Map.get(u0, 39), 39);

eq("File \"bs_map_set_dict_test.res\", line 85, characters 5-12", Belt_Map.get(u1, 39), 120);

let u = Belt_Map.fromArray(Belt_Array.makeByAndShuffle(10000, x => [
  x,
  x
]), Icmp);

eq("File \"bs_map_set_dict_test.res\", line 90, characters 5-12", Belt_Array.makeBy(10000, x => [
  x,
  x
]), Belt_Map.toArray(u));

Mt.from_pair_suites("Bs_map_set_dict_test", suites.contents);

let M;

let MI;

let I;

let A;

let L;

let vv;

let vv2;

let Md0;

let ISet;

let S0;

export {
  suites,
  test_id,
  eq,
  b,
  Icmp,
  Icmp2,
  Ic3,
  M,
  MI,
  I,
  A,
  L,
  m0,
  m00,
  I2,
  m,
  m2,
  vv,
  vv2,
  Md0,
  ISet,
  S0,
  f,
  $eq$tilde,
}
/* Icmp Not a pure module */
