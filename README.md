[![Actions Status](https://github.com/lizmat/path-utils/actions/workflows/test.yml/badge.svg)](https://github.com/lizmat/path-utils/actions)

NAME
====

path::utils - low-level path introspection utility functions

SYNOPSIS
========

```raku
use path-utils;  # export all subs

use path-utils <path-exists>;  # only export sub path-exists

say path-exists($filename);  0 or 1
```

DESCRIPTION
===========

path-utils provides a number of low-level path introspection utility functions for those cases where you're interested in performance, rather than functionality.

All subroutines take a (native) string as the only argument.

Note that these functions only return native `int` and native `num` values, which can be used in conditions without any problems, just don't expect them to be upgraded to `Bool` values.

Also note that all functions (except `path-exists`) expect the path to exist. An exception will be thrown if the path does not exist. The reason for this is that in situations where you are already sure a path exists, there is no point checking for its existence again if you e.g. would like to know its size.

By default all utility functions are exported. But you can limit this to the functions you actually need by specifying the names in the `use` statement.

EXPORTED SUBROUTINES
====================

In alphabetical order:

path-accessed(str $path) {
--------------------------

Returns number of seconds since epoch as a `num` when path was last accessed.

path-blocks(str $path) {
------------------------

Returns the number of filesystem blocks allocated for this path.

path-block-size(str $path) {
----------------------------

Returns the preferred I/O size in bytes for interacting wuth the path.

path-created(str $path) {
-------------------------

Returns number of seconds since epoch as a `num` when path was created.

path-device-number(str $path) {
-------------------------------

Returns the device number of the filesystem on which the path resides.

path-exists(str $path)
----------------------

Returns 1 if paths exists, 0 if not.

path-filesize(str $path) {
--------------------------

Returns the size of the path in bytes.

path-gid(str $path) {
---------------------

Returns the numeric group id of the path.

path-hard-links(str $path) {
----------------------------

Returns the number of hard links to the path.

path-inode(str $path) {
-----------------------

Returns the inode of the path.

path-is-device(str $path) {
---------------------------

Returns 1 if path is a device, 0 if not.

path-is-directory
-----------------

Returns 1 if path is a directory, 0 if not.

path-is-executable(str $path)
-----------------------------

Returns a non-zero integer value if path is executable by `uid`.

path-is-group-executable(str $path)
-----------------------------------

Returns a non-zero integer value if path is executable by `gid`.

path-is-group-readable(str $path)
---------------------------------

Returns a non-zero integer value if path is readable by `gid`.

path-is-group-writable(str $path)
---------------------------------

Returns a non-zero integer value if path is writable by `gid`.

path-is-owned-by-user(str $path)
--------------------------------

Returns a non-zero integer value if path is owned by the current user.

path-is-owned-by-group(str $path)
---------------------------------

Returns a non-zero integer value if path is owned by the group of the current user.

path-is-readable(str $path)
---------------------------

Returns a non-zero integer value if path is readable by `uid`.

path-is-regular-file(str $path) {
---------------------------------

Returns 1 if path is a regular file, 0 if not.

path-is-symbolic-link(str $path) {
----------------------------------

Returns 1 if path is a symbolic link, 0 if not.

path-is-world-executable(str $path)
-----------------------------------

Returns a non-zero integer value if path is executable by any other user.

path-is-world-readable(str $path)
---------------------------------

Returns a non-zero integer value if path is readable by any other user.

path-is-world-writable(str $path)
---------------------------------

Returns a non-zero integer value if path is writable by any other user.

path-is-writable(str $path)
---------------------------

Returns a non-zero integer value if path is writable by `uid`.

path-meta-modified(str $path) {
-------------------------------

Returns number of seconds since epoch as a `num` when the meta information of the path was last modified.

path-mode(str $path) {
----------------------

Returns the numeric unix-style mode.

path-modified(str $path) {
--------------------------

Returns number of seconds since epoch as a `num` when path was last modified.

path-uid(str $path) {
---------------------

Returns the numeric user id of the path.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/path-utils . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

