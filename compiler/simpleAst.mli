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

type simple_type = TyId of Ast.id
		   | TyApp of Ast.id * simple_type list
		   | ValApp of simple_type * HostLanguage.expr
           | Tuple of simple_type list
           | Record of (Ast.id * simple_type) list
           | Datatype of (Ast.id * simple_type option) list
           | Constraint of (simple_type * Ast.id * HostLanguage.expr)
	   | Table of Ast.id * HostLanguage.expr * HostLanguage.expr * Ast.id * Ast.id

val trans : Description.table -> Description.metadata
  -> HostLanguage.tp_ctxt
  -> MLast.loc
  -> Ast.tp_def
  -> simple_type


