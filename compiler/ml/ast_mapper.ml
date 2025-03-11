(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                         Alain Frisch, LexiFi                           *)
(*                                                                        *)
(*   Copyright 2012 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* A generic Parsetree mapping class *)

(*
[@@@warning "+9"]
  (* Ensure that record patterns don't miss any field. *)
*)

open Parsetree
open Ast_helper
open Location

type mapper = {
  attribute: mapper -> attribute -> attribute;
  attributes: mapper -> attribute list -> attribute list;
  case: mapper -> case -> case;
  cases: mapper -> case list -> case list;
  constructor_declaration:
    mapper -> constructor_declaration -> constructor_declaration;
  expr: mapper -> expression -> expression;
  extension: mapper -> extension -> extension;
  extension_constructor:
    mapper -> extension_constructor -> extension_constructor;
  include_declaration: mapper -> include_declaration -> include_declaration;
  include_description: mapper -> include_description -> include_description;
  label_declaration: mapper -> label_declaration -> label_declaration;
  location: mapper -> Location.t -> Location.t;
  module_binding: mapper -> module_binding -> module_binding;
  module_declaration: mapper -> module_declaration -> module_declaration;
  module_expr: mapper -> module_expr -> module_expr;
  module_type: mapper -> module_type -> module_type;
  module_type_declaration:
    mapper -> module_type_declaration -> module_type_declaration;
  open_description: mapper -> open_description -> open_description;
  pat: mapper -> pattern -> pattern;
  payload: mapper -> payload -> payload;
  signature: mapper -> signature -> signature;
  signature_item: mapper -> signature_item -> signature_item;
  structure: mapper -> structure -> structure;
  structure_item: mapper -> structure_item -> structure_item;
  typ: mapper -> core_type -> core_type;
  type_declaration: mapper -> type_declaration -> type_declaration;
  type_extension: mapper -> type_extension -> type_extension;
  type_kind: mapper -> type_kind -> type_kind;
  value_binding: mapper -> value_binding -> value_binding;
  value_description: mapper -> value_description -> value_description;
  with_constraint: mapper -> with_constraint -> with_constraint;
}

let id x = x
let map_fst f (x, y) = (f x, y)
let map_snd f (x, y) = (x, f y)
let map_tuple f1 f2 (x, y) = (f1 x, f2 y)
let map_tuple3 f1 f2 f3 (x, y, z) = (f1 x, f2 y, f3 z)
let map_opt f = function
  | None -> None
  | Some x -> Some (f x)

let map_loc sub {loc; txt} = {loc = sub.location sub loc; txt}

module T = struct
  (* Type expressions for the core language *)

  let row_field sub = function
    | Rtag (l, attrs, b, tl) ->
      Rtag
        (map_loc sub l, sub.attributes sub attrs, b, List.map (sub.typ sub) tl)
    | Rinherit t -> Rinherit (sub.typ sub t)

  let object_field sub = function
    | Otag (l, attrs, t) ->
      Otag (map_loc sub l, sub.attributes sub attrs, sub.typ sub t)
    | Oinherit t -> Oinherit (sub.typ sub t)

  let map sub {ptyp_desc = desc; ptyp_loc = loc; ptyp_attributes = attrs} =
    let open Typ in
    let loc = sub.location sub loc in
    let attrs = sub.attributes sub attrs in
    match desc with
    | Ptyp_any -> any ~loc ~attrs ()
    | Ptyp_var s -> var ~loc ~attrs s
    | Ptyp_arrow {lbl; arg; ret; arity} ->
      arrow ~loc ~attrs ~arity lbl (sub.typ sub arg) (sub.typ sub ret)
    | Ptyp_tuple tyl -> tuple ~loc ~attrs (List.map (sub.typ sub) tyl)
    | Ptyp_constr (lid, tl) ->
      constr ~loc ~attrs (map_loc sub lid) (List.map (sub.typ sub) tl)
    | Ptyp_object (l, o) ->
      object_ ~loc ~attrs (List.map (object_field sub) l) o
    | Ptyp_alias (t, s) -> alias ~loc ~attrs (sub.typ sub t) s
    | Ptyp_variant (rl, b, ll) ->
      variant ~loc ~attrs (List.map (row_field sub) rl) b ll
    | Ptyp_poly (sl, t) ->
      poly ~loc ~attrs (List.map (map_loc sub) sl) (sub.typ sub t)
    | Ptyp_package (lid, l) ->
      package ~loc ~attrs (map_loc sub lid)
        (List.map (map_tuple (map_loc sub) (sub.typ sub)) l)
    | Ptyp_extension x -> extension ~loc ~attrs (sub.extension sub x)

  let map_type_declaration sub
      {
        ptype_name;
        ptype_params;
        ptype_cstrs;
        ptype_kind;
        ptype_private;
        ptype_manifest;
        ptype_attributes;
        ptype_loc;
      } =
    Type.mk (map_loc sub ptype_name)
      ~params:(List.map (map_fst (sub.typ sub)) ptype_params)
      ~priv:ptype_private
      ~cstrs:
        (List.map
           (map_tuple3 (sub.typ sub) (sub.typ sub) (sub.location sub))
           ptype_cstrs)
      ~kind:(sub.type_kind sub ptype_kind)
      ?manifest:(map_opt (sub.typ sub) ptype_manifest)
      ~loc:(sub.location sub ptype_loc)
      ~attrs:(sub.attributes sub ptype_attributes)

  let map_type_kind sub = function
    | Ptype_abstract -> Ptype_abstract
    | Ptype_variant l ->
      Ptype_variant (List.map (sub.constructor_declaration sub) l)
    | Ptype_record l -> Ptype_record (List.map (sub.label_declaration sub) l)
    | Ptype_open -> Ptype_open

  let map_constructor_arguments sub = function
    | Pcstr_tuple l -> Pcstr_tuple (List.map (sub.typ sub) l)
    | Pcstr_record l -> Pcstr_record (List.map (sub.label_declaration sub) l)

  let map_type_extension sub
      {
        ptyext_path;
        ptyext_params;
        ptyext_constructors;
        ptyext_private;
        ptyext_attributes;
      } =
    Te.mk (map_loc sub ptyext_path)
      (List.map (sub.extension_constructor sub) ptyext_constructors)
      ~params:(List.map (map_fst (sub.typ sub)) ptyext_params)
      ~priv:ptyext_private
      ~attrs:(sub.attributes sub ptyext_attributes)

  let map_extension_constructor_kind sub = function
    | Pext_decl (ctl, cto) ->
      Pext_decl (map_constructor_arguments sub ctl, map_opt (sub.typ sub) cto)
    | Pext_rebind li -> Pext_rebind (map_loc sub li)

  let map_extension_constructor sub
      {pext_name; pext_kind; pext_loc; pext_attributes} =
    Te.constructor (map_loc sub pext_name)
      (map_extension_constructor_kind sub pext_kind)
      ~loc:(sub.location sub pext_loc)
      ~attrs:(sub.attributes sub pext_attributes)
end

module MT = struct
  (* Type expressions for the module language *)

  let map sub {pmty_desc = desc; pmty_loc = loc; pmty_attributes = attrs} =
    let open Mty in
    let loc = sub.location sub loc in
    let attrs = sub.attributes sub attrs in
    match desc with
    | Pmty_ident s -> ident ~loc ~attrs (map_loc sub s)
    | Pmty_alias s -> alias ~loc ~attrs (map_loc sub s)
    | Pmty_signature sg -> signature ~loc ~attrs (sub.signature sub sg)
    | Pmty_functor (s, mt1, mt2) ->
      functor_ ~loc ~attrs (map_loc sub s)
        (Misc.may_map (sub.module_type sub) mt1)
        (sub.module_type sub mt2)
    | Pmty_with (mt, l) ->
      with_ ~loc ~attrs (sub.module_type sub mt)
        (List.map (sub.with_constraint sub) l)
    | Pmty_typeof me -> typeof_ ~loc ~attrs (sub.module_expr sub me)
    | Pmty_extension x -> extension ~loc ~attrs (sub.extension sub x)

  let map_with_constraint sub = function
    | Pwith_type (lid, d) ->
      Pwith_type (map_loc sub lid, sub.type_declaration sub d)
    | Pwith_module (lid, lid2) ->
      Pwith_module (map_loc sub lid, map_loc sub lid2)
    | Pwith_typesubst (lid, d) ->
      Pwith_typesubst (map_loc sub lid, sub.type_declaration sub d)
    | Pwith_modsubst (s, lid) -> Pwith_modsubst (map_loc sub s, map_loc sub lid)

  let map_signature_item sub {psig_desc = desc; psig_loc = loc} =
    let open Sig in
    let loc = sub.location sub loc in
    match desc with
    | Psig_value vd -> value ~loc (sub.value_description sub vd)
    | Psig_type (rf, l) -> type_ ~loc rf (List.map (sub.type_declaration sub) l)
    | Psig_typext te -> type_extension ~loc (sub.type_extension sub te)
    | Psig_exception ed -> exception_ ~loc (sub.extension_constructor sub ed)
    | Psig_module x -> module_ ~loc (sub.module_declaration sub x)
    | Psig_recmodule l ->
      rec_module ~loc (List.map (sub.module_declaration sub) l)
    | Psig_modtype x -> modtype ~loc (sub.module_type_declaration sub x)
    | Psig_open x -> open_ ~loc (sub.open_description sub x)
    | Psig_include x -> include_ ~loc (sub.include_description sub x)
    | Psig_extension (x, attrs) ->
      extension ~loc (sub.extension sub x) ~attrs:(sub.attributes sub attrs)
    | Psig_attribute x -> attribute ~loc (sub.attribute sub x)
end

module M = struct
  (* Value expressions for the module language *)

  let map sub {pmod_loc = loc; pmod_desc = desc; pmod_attributes = attrs} =
    let open Mod in
    let loc = sub.location sub loc in
    let attrs = sub.attributes sub attrs in
    match desc with
    | Pmod_ident x -> ident ~loc ~attrs (map_loc sub x)
    | Pmod_structure str -> structure ~loc ~attrs (sub.structure sub str)
    | Pmod_functor (arg, arg_ty, body) ->
      functor_ ~loc ~attrs (map_loc sub arg)
        (Misc.may_map (sub.module_type sub) arg_ty)
        (sub.module_expr sub body)
    | Pmod_apply (m1, m2) ->
      apply ~loc ~attrs (sub.module_expr sub m1) (sub.module_expr sub m2)
    | Pmod_constraint (m, mty) ->
      constraint_ ~loc ~attrs (sub.module_expr sub m) (sub.module_type sub mty)
    | Pmod_unpack e -> unpack ~loc ~attrs (sub.expr sub e)
    | Pmod_extension x -> extension ~loc ~attrs (sub.extension sub x)

  let map_structure_item sub {pstr_loc = loc; pstr_desc = desc} =
    let open Str in
    let loc = sub.location sub loc in
    match desc with
    | Pstr_eval (x, attrs) ->
      eval ~loc ~attrs:(sub.attributes sub attrs) (sub.expr sub x)
    | Pstr_value (r, vbs) -> value ~loc r (List.map (sub.value_binding sub) vbs)
    | Pstr_primitive vd -> primitive ~loc (sub.value_description sub vd)
    | Pstr_type (rf, l) -> type_ ~loc rf (List.map (sub.type_declaration sub) l)
    | Pstr_typext te -> type_extension ~loc (sub.type_extension sub te)
    | Pstr_exception ed -> exception_ ~loc (sub.extension_constructor sub ed)
    | Pstr_module x -> module_ ~loc (sub.module_binding sub x)
    | Pstr_recmodule l -> rec_module ~loc (List.map (sub.module_binding sub) l)
    | Pstr_modtype x -> modtype ~loc (sub.module_type_declaration sub x)
    | Pstr_open x -> open_ ~loc (sub.open_description sub x)
    | Pstr_include x -> include_ ~loc (sub.include_declaration sub x)
    | Pstr_extension (x, attrs) ->
      extension ~loc (sub.extension sub x) ~attrs:(sub.attributes sub attrs)
    | Pstr_attribute x -> attribute ~loc (sub.attribute sub x)
end

module E = struct
  let map_jsx_children sub = function
    | JSXChildrenSpreading e -> JSXChildrenSpreading (sub.expr sub e)
    | JSXChildrenItems xs -> JSXChildrenItems (List.map (sub.expr sub) xs)

  let map_jsx_prop sub = function
    | JSXPropPunning (optional, name) ->
      JSXPropPunning (optional, map_loc sub name)
    | JSXPropValue (name, optional, value) ->
      JSXPropValue (map_loc sub name, optional, sub.expr sub value)
    | JSXPropSpreading (loc, e) ->
      JSXPropSpreading (sub.location sub loc, sub.expr sub e)

  let map_jsx_props sub = List.map (map_jsx_prop sub)

  (* Value expressions for the core language *)

  let map sub {pexp_loc = loc; pexp_desc = desc; pexp_attributes = attrs} =
    let open Exp in
    let loc = sub.location sub loc in
    let attrs = sub.attributes sub attrs in
    match desc with
    | Pexp_ident x -> ident ~loc ~attrs (map_loc sub x)
    | Pexp_constant x -> constant ~loc ~attrs x
    | Pexp_let (r, vbs, e) ->
      let_ ~loc ~attrs r (List.map (sub.value_binding sub) vbs) (sub.expr sub e)
    | Pexp_fun {arg_label = lab; default = def; lhs = p; rhs = e; arity; async}
      ->
      fun_ ~loc ~attrs ~arity ~async lab
        (map_opt (sub.expr sub) def)
        (sub.pat sub p) (sub.expr sub e)
    | Pexp_apply {funct = e; args = l; partial} ->
      apply ~loc ~attrs ~partial (sub.expr sub e)
        (List.map (map_snd (sub.expr sub)) l)
    | Pexp_match (e, pel) ->
      match_ ~loc ~attrs (sub.expr sub e) (sub.cases sub pel)
    | Pexp_try (e, pel) -> try_ ~loc ~attrs (sub.expr sub e) (sub.cases sub pel)
    | Pexp_tuple el -> tuple ~loc ~attrs (List.map (sub.expr sub) el)
    | Pexp_construct (lid, arg) ->
      construct ~loc ~attrs (map_loc sub lid) (map_opt (sub.expr sub) arg)
    | Pexp_variant (lab, eo) ->
      variant ~loc ~attrs lab (map_opt (sub.expr sub) eo)
    | Pexp_record (l, eo) ->
      record ~loc ~attrs
        (List.map (map_tuple3 (map_loc sub) (sub.expr sub) id) l)
        (map_opt (sub.expr sub) eo)
    | Pexp_field (e, lid) ->
      field ~loc ~attrs (sub.expr sub e) (map_loc sub lid)
    | Pexp_setfield (e1, lid, e2) ->
      setfield ~loc ~attrs (sub.expr sub e1) (map_loc sub lid) (sub.expr sub e2)
    | Pexp_array el -> array ~loc ~attrs (List.map (sub.expr sub) el)
    | Pexp_ifthenelse (e1, e2, e3) ->
      ifthenelse ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
        (map_opt (sub.expr sub) e3)
    | Pexp_sequence (e1, e2) ->
      sequence ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
    | Pexp_while (e1, e2) ->
      while_ ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
    | Pexp_for (p, e1, e2, d, e3) ->
      for_ ~loc ~attrs (sub.pat sub p) (sub.expr sub e1) (sub.expr sub e2) d
        (sub.expr sub e3)
    | Pexp_coerce (e, (), t2) ->
      coerce ~loc ~attrs (sub.expr sub e) (sub.typ sub t2)
    | Pexp_constraint (e, t) ->
      constraint_ ~loc ~attrs (sub.expr sub e) (sub.typ sub t)
    | Pexp_send (e, s) -> send ~loc ~attrs (sub.expr sub e) (map_loc sub s)
    | Pexp_letmodule (s, me, e) ->
      letmodule ~loc ~attrs (map_loc sub s) (sub.module_expr sub me)
        (sub.expr sub e)
    | Pexp_letexception (cd, e) ->
      letexception ~loc ~attrs
        (sub.extension_constructor sub cd)
        (sub.expr sub e)
    | Pexp_assert e -> assert_ ~loc ~attrs (sub.expr sub e)
    | Pexp_lazy e -> lazy_ ~loc ~attrs (sub.expr sub e)
    | Pexp_newtype (s, e) ->
      newtype ~loc ~attrs (map_loc sub s) (sub.expr sub e)
    | Pexp_pack me -> pack ~loc ~attrs (sub.module_expr sub me)
    | Pexp_open (ovf, lid, e) ->
      open_ ~loc ~attrs ovf (map_loc sub lid) (sub.expr sub e)
    | Pexp_extension x -> extension ~loc ~attrs (sub.extension sub x)
    | Pexp_jsx_fragment (o, children, c) ->
      jsx_fragment ~loc ~attrs o (map_jsx_children sub children) c
    | Pexp_jsx_unary_element
        {jsx_unary_element_tag_name = name; jsx_unary_element_props = props} ->
      jsx_unary_element ~loc ~attrs (map_loc sub name) (map_jsx_props sub props)
    | Pexp_jsx_container_element
        {
          jsx_container_element_tag_name_start = name;
          jsx_container_element_opening_tag_end = ote;
          jsx_container_element_props = props;
          jsx_container_element_children = children;
          jsx_container_element_closing_tag = closing_tag;
        } ->
      jsx_container_element ~loc ~attrs (map_loc sub name)
        (map_jsx_props sub props) ote
        (map_jsx_children sub children)
        closing_tag
end

module P = struct
  (* Patterns *)

  let map sub {ppat_desc = desc; ppat_loc = loc; ppat_attributes = attrs} =
    let open Pat in
    let loc = sub.location sub loc in
    let attrs = sub.attributes sub attrs in
    match desc with
    | Ppat_any -> any ~loc ~attrs ()
    | Ppat_var s -> var ~loc ~attrs (map_loc sub s)
    | Ppat_alias (p, s) -> alias ~loc ~attrs (sub.pat sub p) (map_loc sub s)
    | Ppat_constant c -> constant ~loc ~attrs c
    | Ppat_interval (c1, c2) -> interval ~loc ~attrs c1 c2
    | Ppat_tuple pl -> tuple ~loc ~attrs (List.map (sub.pat sub) pl)
    | Ppat_construct (l, p) ->
      construct ~loc ~attrs (map_loc sub l) (map_opt (sub.pat sub) p)
    | Ppat_variant (l, p) -> variant ~loc ~attrs l (map_opt (sub.pat sub) p)
    | Ppat_record (lpl, cf) ->
      record ~loc ~attrs
        (List.map (map_tuple3 (map_loc sub) (sub.pat sub) (fun x -> x)) lpl)
        cf
    | Ppat_array pl -> array ~loc ~attrs (List.map (sub.pat sub) pl)
    | Ppat_or (p1, p2) -> or_ ~loc ~attrs (sub.pat sub p1) (sub.pat sub p2)
    | Ppat_constraint (p, t) ->
      constraint_ ~loc ~attrs (sub.pat sub p) (sub.typ sub t)
    | Ppat_type s -> type_ ~loc ~attrs (map_loc sub s)
    | Ppat_lazy p -> lazy_ ~loc ~attrs (sub.pat sub p)
    | Ppat_unpack s -> unpack ~loc ~attrs (map_loc sub s)
    | Ppat_open (lid, p) -> open_ ~loc ~attrs (map_loc sub lid) (sub.pat sub p)
    | Ppat_exception p -> exception_ ~loc ~attrs (sub.pat sub p)
    | Ppat_extension x -> extension ~loc ~attrs (sub.extension sub x)
end

(* Now, a generic AST mapper, to be extended to cover all kinds and
   cases of the OCaml grammar.  The default behavior of the mapper is
   the identity. *)

let default_mapper =
  {
    structure = (fun this l -> List.map (this.structure_item this) l);
    structure_item = M.map_structure_item;
    module_expr = M.map;
    signature = (fun this l -> List.map (this.signature_item this) l);
    signature_item = MT.map_signature_item;
    module_type = MT.map;
    with_constraint = MT.map_with_constraint;
    type_declaration = T.map_type_declaration;
    type_kind = T.map_type_kind;
    typ = T.map;
    type_extension = T.map_type_extension;
    extension_constructor = T.map_extension_constructor;
    value_description =
      (fun this {pval_name; pval_type; pval_prim; pval_loc; pval_attributes} ->
        Val.mk (map_loc this pval_name) (this.typ this pval_type)
          ~attrs:(this.attributes this pval_attributes)
          ~loc:(this.location this pval_loc)
          ~prim:pval_prim);
    pat = P.map;
    expr = E.map;
    module_declaration =
      (fun this {pmd_name; pmd_type; pmd_attributes; pmd_loc} ->
        Md.mk (map_loc this pmd_name)
          (this.module_type this pmd_type)
          ~attrs:(this.attributes this pmd_attributes)
          ~loc:(this.location this pmd_loc));
    module_type_declaration =
      (fun this {pmtd_name; pmtd_type; pmtd_attributes; pmtd_loc} ->
        Mtd.mk (map_loc this pmtd_name)
          ?typ:(map_opt (this.module_type this) pmtd_type)
          ~attrs:(this.attributes this pmtd_attributes)
          ~loc:(this.location this pmtd_loc));
    module_binding =
      (fun this {pmb_name; pmb_expr; pmb_attributes; pmb_loc} ->
        Mb.mk (map_loc this pmb_name)
          (this.module_expr this pmb_expr)
          ~attrs:(this.attributes this pmb_attributes)
          ~loc:(this.location this pmb_loc));
    open_description =
      (fun this {popen_lid; popen_override; popen_attributes; popen_loc} ->
        Opn.mk (map_loc this popen_lid) ~override:popen_override
          ~loc:(this.location this popen_loc)
          ~attrs:(this.attributes this popen_attributes));
    include_description =
      (fun this {pincl_mod; pincl_attributes; pincl_loc} ->
        Incl.mk
          (this.module_type this pincl_mod)
          ~loc:(this.location this pincl_loc)
          ~attrs:(this.attributes this pincl_attributes));
    include_declaration =
      (fun this {pincl_mod; pincl_attributes; pincl_loc} ->
        Incl.mk
          (this.module_expr this pincl_mod)
          ~loc:(this.location this pincl_loc)
          ~attrs:(this.attributes this pincl_attributes));
    value_binding =
      (fun this {pvb_pat; pvb_expr; pvb_attributes; pvb_loc} ->
        Vb.mk (this.pat this pvb_pat) (this.expr this pvb_expr)
          ~loc:(this.location this pvb_loc)
          ~attrs:(this.attributes this pvb_attributes));
    constructor_declaration =
      (fun this {pcd_name; pcd_args; pcd_res; pcd_loc; pcd_attributes} ->
        Type.constructor (map_loc this pcd_name)
          ~args:(T.map_constructor_arguments this pcd_args)
          ?res:(map_opt (this.typ this) pcd_res)
          ~loc:(this.location this pcd_loc)
          ~attrs:(this.attributes this pcd_attributes));
    label_declaration =
      (fun this
        {pld_name; pld_type; pld_loc; pld_mutable; pld_optional; pld_attributes}
      ->
        Type.field (map_loc this pld_name) (this.typ this pld_type)
          ~mut:pld_mutable ~optional:pld_optional
          ~loc:(this.location this pld_loc)
          ~attrs:(this.attributes this pld_attributes));
    cases = (fun this l -> List.map (this.case this) l);
    case =
      (fun this {pc_lhs; pc_guard; pc_rhs} ->
        {
          pc_lhs = this.pat this pc_lhs;
          pc_guard = map_opt (this.expr this) pc_guard;
          pc_rhs = this.expr this pc_rhs;
        });
    location = (fun _this l -> l);
    extension = (fun this (s, e) -> (map_loc this s, this.payload this e));
    attribute = (fun this (s, e) -> (map_loc this s, this.payload this e));
    attributes = (fun this l -> List.map (this.attribute this) l);
    payload =
      (fun this -> function
        | PStr x -> PStr (this.structure this x)
        | PSig x -> PSig (this.signature this x)
        | PTyp x -> PTyp (this.typ this x)
        | PPat (x, g) -> PPat (this.pat this x, map_opt (this.expr this) g));
  }

let rec extension_of_error {loc; msg; if_highlight; sub} =
  ( {loc; txt = "ocaml.error"},
    PStr
      ([
         Str.eval (Exp.constant (Pconst_string (msg, None)));
         Str.eval (Exp.constant (Pconst_string (if_highlight, None)));
       ]
      @ List.map (fun ext -> Str.extension (extension_of_error ext)) sub) )

let attribute_of_warning loc s =
  ( {loc; txt = "ocaml.ppwarning"},
    PStr [Str.eval ~loc (Exp.constant (Pconst_string (s, None)))] )

module StringMap = Map.Make (struct
  type t = string
  let compare = compare
end)

let cookies = ref StringMap.empty

let get_cookie k = try Some (StringMap.find k !cookies) with Not_found -> None

let set_cookie k v = cookies := StringMap.add k v !cookies

let tool_name_ref = ref "_none_"

let tool_name () = !tool_name_ref

module PpxContext = struct
  open Longident
  open Asttypes
  open Ast_helper

  let lid name = {txt = Lident name; loc = Location.none}

  let make_string x = Exp.constant (Pconst_string (x, None))

  let make_bool x =
    if x then Exp.construct (lid "true") None
    else Exp.construct (lid "false") None

  let rec make_list f lst =
    match lst with
    | x :: rest ->
      Exp.construct (lid "::") (Some (Exp.tuple [f x; make_list f rest]))
    | [] -> Exp.construct (lid "[]") None

  let make_pair f1 f2 (x1, x2) = Exp.tuple [f1 x1; f2 x2]

  let get_cookies () =
    ( lid "cookies",
      make_list
        (make_pair make_string (fun x -> x))
        (StringMap.bindings !cookies),
      false )

  let mk fields =
    ( {txt = "ocaml.ppx.context"; loc = Location.none},
      Parsetree.PStr [Str.eval (Exp.record fields None)] )

  let make ~tool_name () =
    let fields =
      [
        (lid "tool_name", make_string tool_name, false);
        (lid "include_dirs", make_list make_string !Clflags.include_dirs, false);
        (lid "load_path", make_list make_string !Config.load_path, false);
        (lid "open_modules", make_list make_string !Clflags.open_modules, false);
        (lid "debug", make_bool !Clflags.debug, false);
        get_cookies ();
      ]
    in
    mk fields

  let get_fields = function
    | PStr
        [{pstr_desc = Pstr_eval ({pexp_desc = Pexp_record (fields, None)}, [])}]
      ->
      fields
    | _ -> raise_errorf "Internal error: invalid [@@@ocaml.ppx.context] syntax"

  let restore fields =
    let field name payload =
      let rec get_string = function
        | {pexp_desc = Pexp_constant (Pconst_string (str, None))} -> str
        | _ ->
          raise_errorf
            "Internal error: invalid [@@@ocaml.ppx.context { %s }] string \
             syntax"
            name
      and get_bool pexp =
        match pexp with
        | {pexp_desc = Pexp_construct ({txt = Longident.Lident "true"}, None)}
          ->
          true
        | {pexp_desc = Pexp_construct ({txt = Longident.Lident "false"}, None)}
          ->
          false
        | _ ->
          raise_errorf
            "Internal error: invalid [@@@ocaml.ppx.context { %s }] bool syntax"
            name
      and get_list elem = function
        | {
            pexp_desc =
              Pexp_construct
                ( {txt = Longident.Lident "::"},
                  Some {pexp_desc = Pexp_tuple [exp; rest]} );
          } ->
          elem exp :: get_list elem rest
        | {pexp_desc = Pexp_construct ({txt = Longident.Lident "[]"}, None)} ->
          []
        | _ ->
          raise_errorf
            "Internal error: invalid [@@@ocaml.ppx.context { %s }] list syntax"
            name
      and get_pair f1 f2 = function
        | {pexp_desc = Pexp_tuple [e1; e2]} -> (f1 e1, f2 e2)
        | _ ->
          raise_errorf
            "Internal error: invalid [@@@ocaml.ppx.context { %s }] pair syntax"
            name
      in
      match name with
      | "tool_name" -> tool_name_ref := get_string payload
      | "include_dirs" -> Clflags.include_dirs := get_list get_string payload
      | "load_path" -> Config.load_path := get_list get_string payload
      | "open_modules" -> Clflags.open_modules := get_list get_string payload
      | "debug" -> Clflags.debug := get_bool payload
      | "cookies" ->
        let l = get_list (get_pair get_string (fun x -> x)) payload in
        cookies :=
          List.fold_left (fun s (k, v) -> StringMap.add k v s) StringMap.empty l
      | _ -> ()
    in
    List.iter
      (function
        | {txt = Lident name}, x, _ -> field name x
        | _ -> ())
      fields

  let update_cookies fields =
    let fields =
      Ext_list.filter fields (function
        | {txt = Lident "cookies"}, _, _ -> false
        | _ -> true)
    in
    fields @ [get_cookies ()]
end

let ppx_context = PpxContext.make

let extension_of_exn exn =
  match error_of_exn exn with
  | Some (`Ok error) -> extension_of_error error
  | Some `Already_displayed ->
    ({loc = Location.none; txt = "ocaml.error"}, PStr [])
  | None -> raise exn

let apply_lazy ~source ~target mapper =
  let implem ast =
    let fields, ast =
      match ast with
      | {pstr_desc = Pstr_attribute ({txt = "ocaml.ppx.context"}, x)} :: l ->
        (PpxContext.get_fields x, l)
      | _ -> ([], ast)
    in
    PpxContext.restore fields;
    let ast =
      try
        let mapper = mapper () in
        mapper.structure mapper ast
      with exn ->
        [
          {
            pstr_desc = Pstr_extension (extension_of_exn exn, []);
            pstr_loc = Location.none;
          };
        ]
    in
    let fields = PpxContext.update_cookies fields in
    Str.attribute (PpxContext.mk fields) :: ast
  in
  let iface ast =
    let fields, ast =
      match ast with
      | {psig_desc = Psig_attribute ({txt = "ocaml.ppx.context"}, x)} :: l ->
        (PpxContext.get_fields x, l)
      | _ -> ([], ast)
    in
    PpxContext.restore fields;
    let ast =
      try
        let mapper = mapper () in
        mapper.signature mapper ast
      with exn ->
        [
          {
            psig_desc = Psig_extension (extension_of_exn exn, []);
            psig_loc = Location.none;
          };
        ]
    in
    let fields = PpxContext.update_cookies fields in
    Sig.attribute (PpxContext.mk fields) :: ast
  in

  let ic = open_in_bin source in
  let magic =
    really_input_string ic (String.length Config.ast_impl_magic_number)
  in

  let rewrite transform =
    Location.set_input_name @@ input_value ic;
    let ast = input_value ic in
    close_in ic;
    let ast = transform ast in
    let oc = open_out_bin target in
    output_string oc magic;
    output_value oc !Location.input_name;
    output_value oc ast;
    close_out oc
  and fail () =
    close_in ic;
    failwith "Ast_mapper: OCaml version mismatch or malformed input"
  in

  if magic = Config.ast_impl_magic_number then
    rewrite (implem : structure -> structure)
  else if magic = Config.ast_intf_magic_number then
    rewrite (iface : signature -> signature)
  else fail ()

let drop_ppx_context_str ~restore = function
  | {pstr_desc = Pstr_attribute ({Location.txt = "ocaml.ppx.context"}, a)}
    :: items ->
    if restore then PpxContext.restore (PpxContext.get_fields a);
    items
  | items -> items

let drop_ppx_context_sig ~restore = function
  | {psig_desc = Psig_attribute ({Location.txt = "ocaml.ppx.context"}, a)}
    :: items ->
    if restore then PpxContext.restore (PpxContext.get_fields a);
    items
  | items -> items

let add_ppx_context_str ~tool_name ast =
  Ast_helper.Str.attribute (ppx_context ~tool_name ()) :: ast

let add_ppx_context_sig ~tool_name ast =
  Ast_helper.Sig.attribute (ppx_context ~tool_name ()) :: ast

let apply ~source ~target mapper = apply_lazy ~source ~target (fun () -> mapper)

let run_main mapper =
  try
    let a = Sys.argv in
    let n = Array.length a in
    if n > 2 then
      let mapper () =
        try mapper (Array.to_list (Array.sub a 1 (n - 3)))
        with exn ->
          (* PR#6463 *)
          let f _ _ = raise exn in
          {default_mapper with structure = f; signature = f}
      in
      apply_lazy ~source:a.(n - 2) ~target:a.(n - 1) mapper
    else (
      Printf.eprintf "Usage: %s [extra_args] <infile> <outfile>\n%!"
        Sys.executable_name;
      exit 2)
  with exn ->
    prerr_endline (Printexc.to_string exn);
    exit 2

let register_function = ref (fun _name f -> run_main f)
let register name f = !register_function name f
