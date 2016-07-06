(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)


type args = (string * Parsetree.expression) list
type loc = Location.t 
type label_exprs = (Longident.t Asttypes.loc * Parsetree.expression) list
type 'a cxt = loc -> Ast_mapper.mapper -> 'a

(** syntax: {[f arg0 arg1 [@bs]]}*)
val uncurry_fn_apply : 
  (Parsetree.expression ->
  args ->
  Parsetree.expression_desc ) cxt 

(** syntax : {[f## arg0 arg1 ]}*)
val method_apply : 
  (Parsetree.expression ->
  string ->
  args ->
  Parsetree.expression_desc) cxt 

(** syntax {[f#@ arg0 arg1 ]}*)
val property_apply : 
  (Parsetree.expression ->
  string ->
  args ->
  Parsetree.expression_desc) cxt 


(** 
    [function] can only take one argument, that is the reason we did not adopt it
    syntax:
    {[ fun [@bs] pat pat1-> body ]}
    [to_uncurry_fn (fun pat -> (fun pat1 -> ...  body))]

*)
val to_uncurry_fn : 
  (Parsetree.pattern ->
   Parsetree.expression ->
   Parsetree.expression_desc) cxt 

(** syntax: 
    {[fun [@bs.this] obj pat pat1 -> body]}    
*)
val to_method_callback : 
  (Parsetree.pattern ->
   Parsetree.expression ->
   Parsetree.expression_desc) cxt 

(** syntax : 
    {[ int -> int -> int [@bs]]}
*)
val to_uncurry_type : 
  (Parsetree.core_type ->
   Parsetree.core_type  ->
   Parsetree.core_type) cxt 

(** syntax
    {[ method : int -> itn -> int ]}
*)
val to_method_type : 
  (Parsetree.core_type ->
  Parsetree.core_type ->
  Parsetree.core_type) cxt 

(** syntax:
    {[ 'obj -> int -> int [@bs.this] ]}
*)
val to_method_callback_type : 
  (Parsetree.core_type ->
  Parsetree.core_type ->  
  Parsetree.core_type) cxt 

val to_js_type : 
  loc -> Parsetree.core_type -> Parsetree.core_type




val record_as_js_object : 
  (label_exprs ->
   Parsetree.expression_desc) cxt 

val js_property : 
  loc ->
  Parsetree.expression -> string -> Parsetree.expression_desc

val handle_debugger : 
  loc -> Ast_payload.t -> Parsetree.expression_desc

val handle_raw : 
  loc -> Ast_payload.t -> Parsetree.expression
val handle_raw_structure : 
  loc -> Ast_payload.t -> Parsetree.structure_item
