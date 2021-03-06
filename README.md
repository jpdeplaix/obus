OBus
====

OBus is a pure OCaml implementation of the D-Bus protocol.  It aims to
provide a clean and easy way for ocaml programmers to access and
provide D-Bus services.

OBus is using the cooperative threading library Lwt, which make it
very simple to fully exploit the asynchronous nature of D-Bus.

Dependencies
------------

* [OCaml](http://caml.inria.fr/ocaml/) (>= 3.12)
* [findlib](http://projects.camlcity.org/projects/findlib.html)
* [react](http://erratique.ch/software/react)
* [lwt](http://ocsigen.org/lwt/) (>= 2.4.0) built with react support
* [type-conv](http://bitbucket.org/yminsky/ocaml-core)
* [xmlm](http://erratique.ch/software/xmlm)

For building the development version, you also need to install
[oasis](http://oasis.forge.ocamlcore.org/) (>= 0.3.0).

Installation
------------

The recommended way to install obus and its dependencies is via
[opam](https://opam.ocaml.org/): `opam install obus`.

Manual installation from sources
--------------------------------

To build and install obus:

    $ ./configure
    $ make
    $ make install

### Documentation and manual pages _(optional)_

To build the documentation:

    $ make doc

It will then be installed by `make install`.

### Tests _(optionnal)_

To build and execute tests:

    $ ./configure --enable-tests
    $ make test

Using the library
-----------------

OBus install the following packages:

* `obus`: the core library, implementing the D-Bus protocol,
* `obus.notification`: interface to the freedesktop Notification
  service,
* `obus.hal`: interface to the freedesktop Hal service,
* `obus.upower`: interface to the freedesktop UPower service,
* `obus.udisks`: interface to the freedesktop UDisks service,
* `obus.policykit`: interface to the freedesktop PolicyKit servie.

Using the tools
---------------

There are several tools provided in the obus distribution:

* `obus-dump`, to execute a command and dump all messages that goes
  throug the session and/or system message bus,
* `obus-introspect` which can recursively introspect a D-Bus service,
* `obus-gen-interface`, to convert D-Bus introspection files into
   ocaml definition modules,
* `obus-gen-client` and obus-gen-server which can generate template
   for using or implementing D-Bus servies,
* `obus-xml2idl` and obus-idl2xml to convert xml introspection
   documents to the obus idl format, and vice versa.

There are manual pages for all this tools.

The caml files generated by obus-gen-client and obus-gen-server are
meant to be edited and adapted. In practice introspections files
contains only marshaling informations so it is often not sufficient
for creating a usable binding.

Here is a simple example of use of the tools:

    $ obus-introspect org.freedesktop.Notifications /org/freedesktop/Notifications > notif.xml
    $ obus-gen-interface notif.xml
    $ obus-gen-client notif.xml
