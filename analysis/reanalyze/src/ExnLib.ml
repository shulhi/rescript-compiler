let raisesLibTable : (Name.t, Exceptions.t) Hashtbl.t =
  let table = Hashtbl.create 15 in
  let open Exn in
  let beltArray =
    [
      ("getExn", [assertFailure]);
      ("getOrThrow", [assertFailure]);
      ("setExn", [assertFailure]);
      ("setOrThrow", [assertFailure]);
    ]
  in
  let beltList =
    [
      ("getExn", [notFound]);
      ("getOrThrow", [notFound]);
      ("headExn", [notFound]);
      ("headOrThrow", [notFound]);
      ("tailExn", [notFound]);
      ("tailOrThrow", [notFound]);
    ]
  in
  let beltMap = [("getExn", [notFound]); ("getOrThrow", [notFound])] in
  let beltMutableMap = beltMap in
  let beltMutableQueue =
    [
      ("peekExn", [notFound]);
      ("peekOrThrow", [notFound]);
      ("popExn", [notFound]);
      ("popOrThrow", [notFound]);
    ]
  in
  let beltSet = [("getExn", [notFound]); ("getOrThrow", [notFound])] in
  let beltMutableSet = beltSet in
  let beltOption = [("getExn", [notFound]); ("getOrThrow", [notFound])] in
  let beltResult = [("getExn", [notFound]); ("getOrThrow", [notFound])] in
  let bsJson =
    (* bs-json *)
    [
      ("bool", [decodeError]);
      ("float", [decodeError]);
      ("int", [decodeError]);
      ("string", [decodeError]);
      ("char", [decodeError]);
      ("date", [decodeError]);
      ("nullable", [decodeError]);
      ("nullAs", [decodeError]);
      ("array", [decodeError]);
      ("list", [decodeError]);
      ("pair", [decodeError]);
      ("tuple2", [decodeError]);
      ("tuple3", [decodeError]);
      ("tuple4", [decodeError]);
      ("dict", [decodeError]);
      ("field", [decodeError]);
      ("at", [decodeError; invalidArgument]);
      ("oneOf", [decodeError]);
      ("either", [decodeError]);
    ]
  in
  let stdlib =
    [
      ("panic", [jsExn]);
      ("assertEqual", [jsExn]);
      ("invalid_arg", [invalidArgument]);
      ("failwith", [failure]);
      ("/", [divisionByZero]);
      ("mod", [divisionByZero]);
      ("char_of_int", [invalidArgument]);
      ("bool_of_string", [invalidArgument]);
      ("int_of_string", [failure]);
      ("float_of_string", [failure]);
    ]
  in
  let stdlibBigInt =
    [
      ("fromStringExn", [jsExn]);
      ("fromStringOrThrow", [jsExn]);
      ("fromFloatOrThrow", [jsExn]);
    ]
  in
  let stdlibBool =
    [
      ("fromStringExn", [invalidArgument]);
      ("fromStringOrThrow", [invalidArgument]);
    ]
  in
  let stdlibJsError =
    [
      ("EvalError.throwWithMessage", [jsExn]);
      ("RangeError.throwWithMessage", [jsExn]);
      ("ReferenceError.throwWithMessage", [jsExn]);
      ("SyntaxError.throwWithMessage", [jsExn]);
      ("TypeError.throwWithMessage", [jsExn]);
      ("URIError.throwWithMessage", [jsExn]);
      ("panic", [jsExn]);
      ("throw", [jsExn]);
      ("throwWithMessage", [jsExn]);
    ]
  in
  let stdlibError =
    [("raise", [jsExn]); ("panic", [jsExn]); ("throw", [jsExn])]
  in
  let stdlibExn =
    [
      ("raiseError", [jsExn]);
      ("raiseEvalError", [jsExn]);
      ("raiseRangeError", [jsExn]);
      ("raiseReferenceError", [jsExn]);
      ("raiseSyntaxError", [jsExn]);
      ("raiseTypeError", [jsExn]);
      ("raiseUriError", [jsExn]);
    ]
  in
  let stdlibJson =
    [
      ("parseExn", [jsExn]);
      ("parseExnWithReviver", [jsExn]);
      ("parseOrThrow", [jsExn]);
      ("stringifyAny", [jsExn]);
      ("stringifyAnyWithIndent", [jsExn]);
      ("stringifyAnyWithReplacer", [jsExn]);
      ("stringifyAnyWithReplacerAndIndent", [jsExn]);
      ("stringifyAnyWithFilter", [jsExn]);
      ("stringifyAnyWithFilterAndIndent", [jsExn]);
    ]
  in
  let stdlibList =
    [("headExn", [notFound]); ("tailExn", [notFound]); ("getExn", [notFound])]
  in
  let stdlibNull = [("getExn", [invalidArgument])] in
  let stdlibNullable = [("getExn", [invalidArgument])] in
  let stdlibOption = [("getExn", [jsExn])] in
  let stdlibResult = [("getExn", [notFound])] in
  let yojsonBasic = [("from_string", [yojsonJsonError])] in
  let yojsonBasicUtil =
    [
      ("member", [yojsonTypeError]);
      ("to_assoc", [yojsonTypeError]);
      ("to_bool", [yojsonTypeError]);
      ("to_bool_option", [yojsonTypeError]);
      ("to_float", [yojsonTypeError]);
      ("to_float_option", [yojsonTypeError]);
      ("to_int", [yojsonTypeError]);
      ("to_list", [yojsonTypeError]);
      ("to_number", [yojsonTypeError]);
      ("to_number_option", [yojsonTypeError]);
      ("to_string", [yojsonTypeError]);
      ("to_string_option", [yojsonTypeError]);
    ]
  in
  [
    ("Belt.Array", beltArray);
    ("Belt_Array", beltArray);
    ("Belt.List", beltList);
    ("Belt_List", beltList);
    ("Belt.Map", beltMap);
    ("Belt.Map.Int", beltMap);
    ("Belt.Map.String", beltMap);
    ("Belt_Map", beltMap);
    ("Belt_Map.Int", beltMap);
    ("Belt_Map.String", beltMap);
    ("Belt_MapInt", beltMap);
    ("Belt_MapString", beltMap);
    ("Belt.MutableMap", beltMutableMap);
    ("Belt.MutableMap.Int", beltMutableMap);
    ("Belt.MutableMap.String", beltMutableMap);
    ("Belt_MutableMap", beltMutableMap);
    ("Belt_MutableMap.Int", beltMutableMap);
    ("Belt_MutableMap.String", beltMutableMap);
    ("Belt_MutableMapInt", beltMutableMap);
    ("Belt_MutableMapString", beltMutableMap);
    ("Belt.MutableQueue", beltMutableQueue);
    ("Belt_MutableQueue", beltMutableQueue);
    ("Belt_MutableSetInt", beltMutableSet);
    ("Belt_MutableSetString", beltMutableSet);
    ("Belt.MutableSet", beltMutableSet);
    ("Belt.MutableSet.Int", beltMutableSet);
    ("Belt.MutableSet.String", beltMutableSet);
    ("Belt.Option", beltOption);
    ("Belt_Option", beltOption);
    ("Belt.Result", beltResult);
    ("Belt_Result", beltResult);
    ("Belt.Set", beltSet);
    ("Belt.Set.Int", beltSet);
    ("Belt.Set.String", beltSet);
    ("Belt_Set", beltSet);
    ("Belt_Set.Int", beltSet);
    ("Belt_Set.String", beltSet);
    ("Belt_SetInt", beltSet);
    ("Belt_SetString", beltSet);
    ("BigInt", stdlibBigInt);
    ("Bool", stdlibBool);
    ("Error", stdlibError);
    ("Exn", stdlibExn);
    ("JsError", stdlibJsError);
    ("Js.Json", [("parseExn", [jsExn])]);
    ("JSON", stdlibJson);
    ("Json_decode", bsJson);
    ("Json.Decode", bsJson);
    ("List", stdlibList);
    ("MutableSet", beltMutableSet);
    ("MutableSet.Int", beltMutableSet);
    ("MutableSet.String", beltMutableSet);
    ("Null", stdlibNull);
    ("Nullable", stdlibNullable);
    ("Option", stdlibOption);
    ("Pervasives", stdlib);
    ("Result", stdlibResult);
    ("Stdlib", stdlib);
    ("Stdlib_BigInt", stdlibBigInt);
    ("Stdlib.BigInt", stdlibBigInt);
    ("Stdlib_Bool", stdlibBool);
    ("Stdlib.Bool", stdlibBool);
    ("Stdlib_Error", stdlibError);
    ("Stdlib.Error", stdlibError);
    ("Stdlib_Exn", stdlibExn);
    ("Stdlib.Exn", stdlibExn);
    ("Stdlib_JsError", stdlibJsError);
    ("Stdlib.JsError", stdlibJsError);
    ("Stdlib_JSON", stdlibJson);
    ("Stdlib.JSON", stdlibJson);
    ("Stdlib_List", stdlibList);
    ("Stdlib.List", stdlibList);
    ("Stdlib_Null", stdlibNull);
    ("Stdlib.Null", stdlibNull);
    ("Stdlib_Nullable", stdlibNullable);
    ("Stdlib.Nullable", stdlibNullable);
    ("Stdlib_Option", stdlibOption);
    ("Stdlib.Option", stdlibOption);
    ("Stdlib_Result", stdlibResult);
    ("Stdlib.Result", stdlibResult);
    ("Yojson.Basic", yojsonBasic);
    ("Yojson.Basic.Util", yojsonBasicUtil);
  ]
  |> List.iter (fun (name, group) ->
         group
         |> List.iter (fun (s, e) ->
                Hashtbl.add table
                  (name ^ "." ^ s |> Name.create)
                  (e |> Exceptions.fromList)));
  table

let find (path : Common.Path.t) =
  Hashtbl.find_opt raisesLibTable (path |> Common.Path.toName)
