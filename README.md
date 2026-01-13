[![Actions Status](https://github.com/lizmat/path-utils/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/path-utils/actions) [![Actions Status](https://github.com/lizmat/path-utils/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/path-utils/actions) [![Actions Status](https://github.com/lizmat/path-utils/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/path-utils/actions)

NAME
====

path-utils - low-level path introspection utility functions

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

SELECTIVE IMPORTING
===================

```raku
use path-utils <path-exists>;  # only export sub path-exists
```

By default all utility functions are exported. But you can limit this to the functions you actually need by specifying the names in the `use` statement.

To prevent name collisions and/or import any subroutine with a more memorable name, one can use the "original-name:known-as" syntax. A semi-colon in a specified string indicates the name by which the subroutine is known in this distribution, followed by the name with which it will be known in the lexical context in which the `use` command is executed.

```raku
use path-utils <path-exists:alive>;  # export "path-exists" as "alive"

say alive "/etc/passwd";  # 1 if on Unixy, 0 on Windows
```

EXPORTED SUBROUTINES
====================

In alphabetical order:

path-accessed
-------------

Returns number of seconds since epoch as a `num` when path was last accessed.

path-blocks
-----------

Returns the number of filesystem blocks allocated for this path.

path-block-size
---------------

Returns the preferred I/O size in bytes for interacting wuth the path.

path-created
------------

Returns number of seconds since epoch as a `num` when path was created.

path-device-number
------------------

Returns the device number of the filesystem on which the path resides.

path-exists
-----------

Returns 1 if paths exists, 0 if not.

path-filesize
-------------

Returns the size of the path in bytes.

path-gid
--------

Returns the numeric group id of the path.

path-git-repo
-------------

Returns the path of the Git repository associated with the **absolute** path given, or returns the empty string if the path is not part inside a Git repository. Note that this not mean that the file is actually part of that Git repository: it merely indicates that the returned path returned `True` with `path-is-git-repo`.

path-hard-links
---------------

Returns the number of hard links to the path.

path-has-setgid
---------------

The path has the SETGID bit set in its attributes.

path-inode
----------

Returns the inode of the path.

path-is-device
--------------

Returns 1 if path is a device, 0 if not.

path-is-directory
-----------------

Returns 1 if path is a directory, 0 if not.

path-is-empty
-------------

Returns 1 if the path has a filesize of 0.

path-is-executable
------------------

Returns a non-zero integer value if path is executable by the current user.

path-is-github-repo
-------------------

Returns 1 if path appears to be the top directory in a GitHub repository (as recognized by having a `.github` directory in it).

path-is-git-repo
----------------

Returns 1 if path appears to be the top directory in a Git repository (as recognized by having a <.git> directory in it).

path-is-group-executable
------------------------

Returns a non-zero integer value if path is executable by members of the group of the path.

path-is-group-readable
----------------------

Returns a non-zero integer value if path is readable by members of the group of the path.

path-is-group-writable
----------------------

Returns a non-zero integer value if path is writable by members of the group of the path.

path-is-moarvm
--------------

Returns 1 if path is a `MoarVM` bytecode file (either from core, or from a precompiled module file), 0 if not.

path-is-owned-by-user
---------------------

Returns a non-zero integer value if path is owned by the current user.

path-is-owned-by-group
----------------------

Returns a non-zero integer value if path is owned by the group of the current user.

path-is-owner-executable
------------------------

Returns a non-zero integer value if path is executable by the owner of the path.

path-is-owner-readable
----------------------

Returns a non-zero integer value if path is readable by the owner of the path.

path-is-owner-writable
----------------------

Returns a non-zero integer value if path is writable by the owner of the path.

path-is-pdf
-----------

Returns 1 if path looks a `PDF` file, judging by its magic number, 0 if not.

path-is-readable
----------------

Returns a non-zero integer value if path is readable by the current user.

path-is-regular-file
--------------------

Returns 1 if path is a regular file, 0 if not.

path-is-sticky
--------------

The path has the STICKY bit set in its attributes.

path-is-sqlite
--------------

Returns 1 if path is a `SQLite` database file.

path-is-symbolic-link
---------------------

Returns 1 if path is a symbolic link, 0 if not.

path-is-text
------------

Returns 1 if path looks like it contains text, 0 if not.

path-is-world-executable
------------------------

Returns a non-zero integer value if path is executable by anybody.

path-is-world-readable
----------------------

Returns a non-zero integer value if path is readable by anybody.

path-is-world-writable
----------------------

Returns a non-zero integer value if path is writable by any body.

path-is-writable
----------------

Returns a non-zero integer value if path is writable by the current user.

path-meta-modified
------------------

Returns number of seconds since epoch as a `num` when the meta information of the path was last modified.

path-mode
---------

Returns the numeric unix-style mode.

path-modified
-------------

Returns number of seconds since epoch as a `num` when path was last modified.

path-uid
--------

Returns the numeric user id of the path.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/path-utils . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2022, 2023, 2024, 2025, 2026 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

