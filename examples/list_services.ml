(*
 * list_services.ml
 * ----------------
 * Copyright : (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

(* List services with their owner *)

open Lwt
open Lwt_io

let list name get_bus =
  lwt () = printlf "service name mapping on %s bus:" name in
  lwt bus = get_bus () in

  (* Get the list of all names on the session bus *)
  lwt names = OBus_bus.list_names bus in

  Lwt_list.iter_p
    (fun name ->
       lwt owner = OBus_bus.get_name_owner bus name in
       printlf "  %s -> %s" owner name)

    (* Select only names which are not connection unique names *)
    (List.filter (fun s -> s.[0] <> ':') names)

lwt () =
  lwt () = list "session" OBus_bus.session in
  list "system" OBus_bus.system
