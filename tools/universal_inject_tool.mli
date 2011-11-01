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

include Generic_tool.S with type state = universal
