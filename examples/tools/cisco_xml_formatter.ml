(***********************************************************************
*                                                                      *
*             This software is part of the padsml package              *
*           Copyright (c) 2006-2009 AT&T Knowledge Ventures            *
*                      and is licensed under the                       *
*                        Common Public License                         *
*                      by AT&T Knowledge Ventures                      *
*                                                                      *
*                A copy of the License is available at                 *
*                    www.padsproj.org/License.html                     *
*                                                                      *
*  This program contains certain software code or other information    *
*  ("AT&T Software") proprietary to AT&T Corp. ("AT&T").  The AT&T     *
*  Software is provided to you "AS IS". YOU ASSUME TOTAL RESPONSIBILITY*
*  AND RISK FOR USE OF THE AT&T SOFTWARE. AT&T DOES NOT MAKE, AND      *
*  EXPRESSLY DISCLAIMS, ANY EXPRESS OR IMPLIED WARRANTIES OF ANY KIND  *
*  WHATSOEVER, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF*
*  MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, WARRANTIES OF  *
*  TITLE OR NON-INFRINGEMENT.  (c) AT&T Corp.  All rights              *
*  reserved.  AT&T is a registered trademark of AT&T Corp.             *
*                                                                      *
*                   Network Services Research Center                   *
*                          AT&T Labs Research                          *
*                           Florham Park NJ                            *
*                                                                      *
*            Yitzhak Mandelbaum <yitzhak@research.att.com>>            *
*              Artem Gleyzer <agleyzer@cs.princeton.edu>               *
*                                 kzhu                                 *
*                                                                      *
***********************************************************************)
(* XML formatter tool: Traverses an arbitrary data source
 * and outputs the data formatted with XML tags. Specifically,
 * this tool uses the MotionTwin XML-Light library to
 * generate a Xml.xml object as its final state that
 * contains tagged data items collected throughout the
 * traversal. *)

(* State: Collects data values into an Xml.xml structure *)
type state = Xml.xml list
type global_state = state

(* Wrap up top-level list of XML elements into single xml element. *)
let wrap elements name = Xml.Element(name,[],elements)

(* An error condition in the execution of a tool
 * state: The state at the moment of the error
 * string: An error msg *)
exception Tool_error of state * string
  
(* Global tool initialization *)
let init () = ()

let ec_to_string = Pads.string_of_error_code

(* Split a string in two. Prefix is up to, but not including
   sep. Suffix is everything after sep. *)
let split sep s = 
  let sep_re = Str.regexp_string sep in
    Str.split sep_re s

let is_sub sub s start length =
  let rec check sub_i s_i =
    if sub_i = length then 
      true
    else if not (sub.[sub_i] = s.[s_i]) then
      false
    else
      check (sub_i + 1) (s_i + 1)
  in
    check 0 start

let is_suffix s suf = 
  let s_len = String.length s in
  let suf_len = String.length suf in
    if suf_len > s_len then false
    else
      is_sub suf s (s_len - suf_len) suf_len

let is_prefix s pre = 
  let s_len = String.length s in
  let pre_len = String.length pre in
    if pre_len > s_len then false
    else
      is_sub pre s 0 pre_len

let hdr_to_xml (h : Pads.pd_header) =
  Xml.Element ("pd", [], 
	      [Xml.Element("nerr",[],[Xml.PCData (string_of_int h.Pads.nerr)]);
	       Xml.Element("error_code",[],[Xml.PCData (ec_to_string h.Pads.error_code)])])
    
let process_hdr pd_hdr = 
  match pd_hdr.Pads.error_code with
      Pads.Good -> [] (* Blank partial state *)
    | _ -> [hdr_to_xml pd_hdr]
	
let process_base result base_to_string pd_hdr =
  match result with
      Pads.Ok r -> [Xml.PCData(base_to_string r)]
    | Pads.Error -> [hdr_to_xml pd_hdr]
	
module Int = struct
  type t = int
  type state = global_state
  let init _ = []
  let process _ result pd_hdr = process_base result string_of_int pd_hdr
end

module Float = struct
  type t = float
  type state = global_state
  let init _ = []
  let process _ result pd_hdr = process_base result string_of_float pd_hdr
end

module Char = struct
  type t = char
  type state = global_state
  let init _ = []
  let process _ result pd_hdr = process_base result (String.make 1) pd_hdr
end

module String = struct
  type t = string
  type state = global_state
  let init _ = []
  let process _ result pd_hdr = process_base result (fun s -> s) pd_hdr
end

module Unit = struct
  type t = unit
  type state = global_state
  let init () = []
  let process _ result pd_hdr = process_base result (fun () -> "") pd_hdr
end

module Extension = struct
  type t = Generic_common.BTExtension.t * string
  type state = global_state
  let init () = []
  let process _ result pd_hdr = process_base result (fun (_,s) -> s) pd_hdr
end

(* Records are XML objects with nested components *)
module Record = struct
  (* Partial state is a list of XML objects representing the
   * fields processed so far and an optional prefix representing
   * an open virtual (not in description) container. *)
  type partial_state = state * (string * Xml.xml list) option

  let init named_states = []

  let start state pd_hdr = process_hdr pd_hdr, None

  let project state field_name = []

    (* Build up list in **reverse** order *)
  let process_field (fields,c_opt) field_name field_state =
    if (is_prefix field_name "c__") then
        match (split "__" field_name) with 
            [_;container_name;element_name] ->          
              (match c_opt with
                  None -> 
                    (* Open a new nested container_name. *)
                    fields, Some (container_name, [Xml.Element (element_name, [], field_state)])
                | Some (c, elements) when c = container_name ->
                    (* Add to an existing nested container_name.
                       Build up list in **reverse** order *)
                    fields, Some (container_name, (Xml.Element (element_name, [], field_state))::elements)
                | Some (c, elements) ->
                    (* Close an open nested container_name. Start a new one. *)
                    let old_cont = Xml.Element (c, [], List.rev elements) in
                      old_cont::fields, Some (container_name, [Xml.Element (element_name, [], field_state)]))
          | _ -> raise (Failure ("Unexpected field name with c__ prefix: " ^ field_name))
    else
      let fields_new = 
        match c_opt with
            None -> fields
          | Some (c,elements) -> (Xml.Element (c, [], List.rev elements))::fields (* close an open container. *) 
      in
	if is_prefix field_name "f__" then
	  (* Remove suffix that was appended to make the name unique. *)
	  match split "__" field_name with 
              [_;core_field_name;_] -> (Xml.Element (core_field_name, [], field_state))::fields_new, None
        | _ -> raise (Failure ("Unexpected field name with f__ prefix: " ^ field_name))
	else if (is_prefix field_name "elt") 
	  || (is_suffix field_name "_start") 
	  || (is_suffix field_name "_members") 
	then
          List.rev_append field_state fields_new, None
        else
          (Xml.Element (field_name, [], field_state))::fields_new, None

  let process_last_field state field_name field_state =
    let fields, c_opt = process_field state field_name field_state in
    let final_fields =
      match c_opt with
	  None -> fields
	| Some(c,elements) -> (Xml.Element (c, [], List.rev elements))::fields
    in
      List.rev final_fields

end

module Datatype = struct
  type partial_state = state

  let init () = []

  let start _ pd_hdr = process_hdr pd_hdr

  let project state variant_name = None

  let process_variant state variant_name variant =
    if is_prefix variant_name "C__" then
      match split "__" variant_name with 
          [_;container_name;element_name] ->          
	    let elements = [Xml.Element (element_name, [], variant)] in
	      [Xml.Element (container_name, [], elements)]
        | _ -> raise (Failure ("Unexpected variant name with C__ prefix: " ^ variant_name))
    else if is_prefix variant_name "F__" then
      (* Remove suffix that was appended to make the name unique. *)
      match split "__" variant_name with 
          [_;core_variant_name;_] -> state @ [Xml.Element (core_variant_name, [], variant)]
        | _ -> raise (Failure ("Unexpected variant name with F__ prefix: " ^ variant_name))
    else if variant_name = "Some" 
      || variant_name = "None" 
      || is_prefix variant_name "Variant__00" 
    then
      variant
    else
      state @ [Xml.Element (variant_name, [], variant)]

  module Empty = struct
    let init () = []
    let process state = state
  end
end

module Constraint = struct
  type partial_state = state

  let init _ = []

  let start _ pd_hdr = process_hdr pd_hdr

  let project state = []

  let process state sub_state = state @ sub_state
end

(** Functions for lists. *)
module List = struct
  
  type partial_state = state list

  let init () = []

  let start _ pd_hdr = [process_hdr pd_hdr]

  let project_next s = (s,None)

  let process_next elts elt_s = elt_s::elts

  let process_last elts elt_s = List.flatten (List.rev (elt_s::elts))

  let process_empty p_state = []

end
