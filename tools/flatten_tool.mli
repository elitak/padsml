type labeled_data = 
      Unlabeled of string 
    | Suffix_labeled of string * string
    | Labeled of string * string

type mail_header_data = labeled_data list

include Generic_tool.S with type state = mail_header_data
