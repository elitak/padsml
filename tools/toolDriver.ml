module Debug_test (Ty:Type.S) =
struct
  module Source = Type.Convert_type (Ty)
  module TDebug = Source.Traverse(Debug_tool)
    
  let in_stream =     
    if Array.length Sys.argv > 1 
    then Sys.argv.(1) 
    else "/dev/stdin"

  let (r,pd) = PadsEasy.parse_source_debug Source.parse in_stream true
  let _ = print_endline "Debug output:"
  let sDebug = TDebug.init ()
  let _ = TDebug.traverse r pd sDebug
end

module XML_test (Ty:Type.S) =
struct
  module Source = Type.Convert_type (Ty)
  module T = Source.Traverse(Xml_formatter)
    
  let in_stream =     
    if Array.length Sys.argv > 1 
    then Sys.argv.(1) 
    else "/dev/stdin"

  let (r,pd) = PadsEasy.parse_source Source.parse in_stream true
  let s = T.init ()
  let xml = T.traverse r pd s
  let print_xml x =
    print_endline (Xml.to_string_fmt x)
  ;;
    List.iter print_xml xml
end

module XML_test_norec (Ty:Type.S) =
struct
  module Source = Type.Convert_type (Ty)
  module T = Source.Traverse(Xml_formatter)
    
  let in_stream =     
    if Array.length Sys.argv > 1 
    then Sys.argv.(1) 
    else "/dev/stdin"

  let (r,pd) = PadsEasy.parse_source Source.parse in_stream false
  let s = T.init ()
  let xml = T.traverse r pd s
  let print_xml () x =
    print_endline (Xml.to_string_fmt x)
  ;;
    List.fold_left print_xml () xml
end

module Debug_test_norec (Ty:Type.S) =
struct
  module Source = Type.Convert_type (Ty)
  module TDebug = Source.Traverse(Debug_tool)
    
  let in_stream =     
    if Array.length Sys.argv > 1 
    then Sys.argv.(1) 
    else "/dev/stdin"

  let (r,pd) = PadsEasy.parse_source Source.parse in_stream false
  let _ = print_endline "Debug output:"
  let sDebug = TDebug.init ()
  let _ = TDebug.traverse r pd sDebug
end

module Parse_test (D:Type.Description) =
struct
  let in_stream =     
    if Array.length Sys.argv > 1 
    then Sys.argv.(1) 
    else "/dev/stdin"

  let (r,pd) = PadsEasy.parse_source D.Source.parse in_stream D.__PML__has_records

  ;;
  if Pads.pd_is_ok pd then print_endline "Success" 
  else print_endline ("Failure:\n" ^ Pads.string_of_pd_hdr (Pads.get_pd_hdr pd))
end
