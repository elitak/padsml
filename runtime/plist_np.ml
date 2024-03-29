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
*                                 kzhu                                 *
*                                                                      *
***********************************************************************)
(* A list with no predicates - no sep and no term. Runs until eor or eof. *)

type 'a plist_np = 'a list
type 'a_pdb plist_np_pd_body = 'a_pdb Pads.pd list

module Plist_np_orig = 
  Plist_gen.Make_plist(
    struct 
      type sep = unit
      type term = unit
      type proc_sep = sep
      type proc_term = term

      let pre_process_sep sep pads = sep
      let pre_process_term term pads = term

      let post_process_sep proc_sep pads = ()
      let post_process_term proc_term pads = ()

      let absorb_sep s h pads = Some h
      let term_match pads t i = Padsc.P_ERR

      let print_sep () pads = ()
    end)

module Plist_np = struct
  type 'a_rep rep = 'a_rep Plist_np_orig.rep
  type 'a_pdb pd_body = 'a_pdb Plist_np_orig.pd_body
  type 'a_pdb pd = 'a_pdb Plist_np_orig.pd
      
  let parse a_parse = Plist_np_orig.parse a_parse ((),())
  let print a_print = Plist_np_orig.print a_print ((),())
  let gen_pd a_gen_pd = Plist_np_orig.gen_pd a_gen_pd ((),())    
  let specialize_tool = Plist_np_orig.specialize_tool
  let specialize_lazy_tool = Plist_np_orig.specialize_lazy_tool
  let specialize_producer = Plist_np_orig.specialize_producer

  open Generic
  module UnitGFTys = GenFunTys.Make(UnitClass)
  let tyrep alpha_tyrep = {UnitGFTys.trep = fun tool ->  
	(* TODO we need to incorporate the separator somehow *)
	tool.UnitGFTys.list alpha_tyrep} 

end
