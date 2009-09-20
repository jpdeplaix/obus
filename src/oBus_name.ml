(*
 * oBus_name.ml
 * ------------
 * Copyright : (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implemtation of dbus.
 *)

open String
open OBus_string

type bus = string
type interface = string
type member = string
type error = string

let alpha ch = (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')
let underscore ch = ch = '_'
let hyphen ch = ch = '-'
let digit ch = ch >= '0' && ch <= '9'

(*** Common names, which are of the form element1.element2.element3... ***)

(* [validate_from str i] test that the name in [str] starting at [i]
   is valid *)
let validate_from typ valid_char str i =
  let fail i msg = Some{ typ = typ; str = str; ofs = i; msg = msg }
  and len = length str in

  let rec aux_element_start i =
    if i = len then
      fail i "empty element"
    else if valid_char (unsafe_get str i) then
      aux_element (i + 1)
    else if unsafe_get str i = '.' then
      fail i "empty element"
    else
      fail i "invalid character"

  and aux_element i =
    if i = len then
      None
    else
      let ch = unsafe_get str i in
      if ch = '.' then
        aux_element_start (i + 1)
      else if valid_char ch || digit ch then
        aux_element (i + 1)
      else
        fail i "invalid character"

  and aux_first_element_start i =
    if i = len then
      fail i "empty element"
    else if valid_char (unsafe_get str i) then
      aux_first_element (i + 1)
    else if unsafe_get str i = '.' then
      fail i "empty element"
    else
      fail i "invalid character"

  and aux_first_element i =
    if i = len then
      fail (-1) "must contains at least two elements"
    else
      let ch = unsafe_get str i in
      if ch = '.' then
        aux_element_start (i + 1)
      else if valid_char ch || digit ch then
        aux_first_element (i + 1)
      else
        fail i "invalid character"

  in

  if len > Constant.max_name_length then
    fail (-1) "name too long"
  else
    aux_first_element_start i

let validate typ valid_char = function
  | "" -> Some{ typ = typ; str = ""; ofs = -1; msg = "empty name" }
  | n -> validate_from typ valid_char n 0

let validate_interface str = validate "interface name" (fun ch -> alpha ch || underscore ch) str
let validate_error str = validate "error name" (fun ch -> alpha ch || underscore ch) str

let validate_bus = function
  | "" ->
      Some{ typ = "bus name"; str = ""; ofs = -1; msg = "empty name" }
  | str when unsafe_get str 0 = ':' ->
      validate_from "unique connection name" (fun ch -> alpha ch || underscore ch || hyphen ch || digit ch) str 1
  | str ->
      validate_from "bus name" (fun ch -> alpha ch || underscore ch || hyphen ch) str 0

let validate_member str =
  let fail i msg = Some{ typ = "member name"; str = str; ofs = i; msg = msg }
  and len = length str in

  let rec aux i =
    if i = len then
      None
    else
      let ch = unsafe_get str i in
      if alpha ch || underscore ch || digit ch then
        aux (i + 1)
      else
        fail i "invalid character"
  in

  if len = 0 then
    Some{ typ = "member name"; str = str; ofs = -1; msg = "empty name" }
  else if len > Constant.max_name_length then
    Some{ typ = "member name"; str = str; ofs = -1; msg = "name too long" }
  else
    let ch = unsafe_get str 0 in
    if alpha ch || underscore ch then
      aux 1
    else
      fail 0 "invalid character"

let is_unique name = length name > 0 && unsafe_get name 0 = ':'

(* Split a name into blocks. Blocks are the longest sub-strings
   matched by the regulare expression: "[A-Z]*[^A-Z.]*" *)
let split name =

  (* Recognize the first part of a block: "[A-Z]*" *)
  let rec part1 i =
    if i = String.length name then
      i
    else
      match name.[i] with
        | 'A' .. 'Z' ->
            part1 (i + 1)
        | _ ->
            part2 i

  (* Recognize the second part of a block: "[^A-Z.]*" *)
  and part2 i =
    if i = String.length name then
      i
    else
      match name.[i] with
        | 'A' .. 'Z' | '.' ->
            i
        | _ ->
            part2 (i + 1)

  in

  let rec split i =
    if i = String.length name then
      []
    else
      let j = part1 i in
      if j = i then
        (* Skip empty blocks *)
        split (i + 1)
      else
        String.sub name i (j - i) :: split j

  in
  split 0

let ocaml_lid name = String.uncapitalize (String.concat "_" (List.map String.lowercase (split name)))
let ocaml_uid name = String.capitalize (String.concat "_" (List.map String.lowercase (split name)))

let haskell_lid name = String.uncapitalize (String.concat "" (split name))
let haskell_uid name = String.capitalize (String.concat "" (split name))