(*
 * eject.ml
 * --------
 * Copyright : (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

(* Simple sample which eject all cdroms using Hal *)

open Lwt
open Lwt_io

lwt () =
  lwt manager = Hal_manager.manager () in
  lwt cdroms = Hal_manager.find_device_by_capability manager "storage.cdrom" in
  lwt () = printlf "cdrom(s) found: %d" (List.length cdroms) in
  Lwt_list.iter_p begin function cdrom ->
    lwt () = printlf "eject on device %s" (OBus_path.to_string (OBus_proxy.path (Hal_device.to_proxy cdrom))) in
    lwt _ = Hal_device.Storage.eject cdrom [] in
    return ()
  end cdroms
