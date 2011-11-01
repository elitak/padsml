(** Parse the source and print it with the Debug tool. 
    The name of the source file is optionally specified on the command line as the first argument.
    In the absence of a first argument, reads from stdin.

    Assumes that the format uses a newline record discipline.

    Returns nothing. *)
module Debug_test (Ty:Type.S) : sig end

(** Parse the source and print it with the Debug tool. 
    The name of the source file is optionally specified on the command line as the first argument.
    In the absence of a first argument, reads from stdin.

    Assumes that the format uses no record discipline.

    Returns nothing. *)
module Debug_test_norec (Ty:Type.S) : sig end

(** Parse the source and convert it to XML.
    The name of the source file is optionally specified on the command line as the first argument.
    In the absence of a first argument, reads from stdin.

    Assumes that the format uses a newline record discipline.

    Returns nothing. *)
module XML_test (Ty:Type.S) : sig end

(** Parse the source and convert it to XML.
    The name of the source file is optionally specified on the command line as the first argument.
    In the absence of a first argument, reads from stdin.

    Assumes that the format uses no record discipline.

    Returns nothing. *)
module XML_test_norec (Ty:Type.S) : sig end

(** Attempt to parse the source and print result. *)
module Parse_test (D:Type.Description) : sig end
