(* Embed the data in the universal datatype. *)

type universal =
    IntData of int
  | FloatData of float
  | CharData of char
  | StringData of string
  | UnitData
  | ExtensionData of Generic_common.BTExtension.t * string 
  | ErrorData
  | RecordData of (string * universal) list
  | DatatypeData of string * universal
  | ConstraintData of universal
  | ListData of universal list

type state = universal
(* To avoid shadowing probelms in base type, we provide this alias for the state type. *)
type global_state = state

(* An error condition in the execution of a tool
 * state: The state at the moment of the error
 * string: An error msg *)
exception Tool_error of state * string
  
(* Global tool initialization *)
let init () = ()

let ec_to_string = Pads.string_of_error_code

let hdr_to_string (h : Pads.pd_header) = "ERROR"    

(* let process_hdr pd_hdr =  *)
(*   match pd_hdr.Pads.error_code with *)
(*       Pads.Good -> [] (\* Blank partial state *\) *)
(*     | _ -> [hdr_to_string pd_hdr] *)
	
(* c is the appropriate constructor for the base type. *)
let process_base result c pd_hdr =
(* as base types are leaves of the tree, we demand that the list be empty. *)
  match result with
      Pads.Ok r -> c r
    | Pads.Error -> ErrorData
	
let init_base = UnitData

module Int = struct
  type t = int
  type state = global_state
  let init _ = init_base
  let process state result pd_hdr = process_base result (fun i->IntData i) pd_hdr
end

module Float = struct
  type t = float
  type state = global_state
  let init _ = init_base
  let process state result pd_hdr = process_base result (fun i->FloatData i) pd_hdr
end

module Char = struct
  type t = char
  type state = global_state
  let init _ = init_base
  let process state result pd_hdr = process_base result (fun c->CharData c) pd_hdr
end

(* Name it StringImpl here so that it doesn't shadow the pervasive String module.
   Rebind at end of module.
 *)
module StringImpl = struct
  type t = string
  type state = global_state
  let init _ = init_base
  let process state result pd_hdr = process_base result (fun s ->StringData s) pd_hdr
end

module Unit = struct
  type t = unit
  type state = global_state
  let init () = init_base
  let process state result pd_hdr = process_base result (fun () -> UnitData) pd_hdr
end

module Extension = struct
  let init () = init_base
  let process bty state result pd_hdr = process_base result (fun s -> ExtensionData (bty,s)) pd_hdr
end

module Record = struct
  (* Partial state is a list of universals representing
   * fields processed so far. *)
  type partial_state = (string * universal) list

  let init named_states = init_base

  let project _ field_name = init_base

  let start _ pd_hdr = []

    (* Build up list in **reverse** order *)
  let process_field fields field_name field_data = (field_name, field_data)::fields
  let process_last_field fields field_name field_data = RecordData (List.rev (process_field fields field_name field_data))
end

module Datatype = struct
  type partial_state = unit

  let init () = init_base

  let start _ pd_hdr = ()

  let project state variant_name = None

  let process_variant () variant_name variant_data = DatatypeData (variant_name,variant_data)
  let process_empty_variant () variant_name = DatatypeData (variant_name,UnitData)
end

module Constraint = struct
  type partial_state = unit

  let init _ = init_base

  let start in_data pd_hdr = ()

  let project _ = init_base

  let process _ sub_out = ConstraintData sub_out
end

module List = struct
  
  type partial_state = universal list

  let init () = init_base

  let start _ pd_hdr = []

  let project_next s = (init_base,None)

  let process_next elts elt_out = elt_out::elts

  let process_last elts elt_out = ListData (List.rev (elt_out::elts))

  let process_empty pstate = ListData pstate

end

module String = StringImpl
