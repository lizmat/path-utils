# This is a naughty module
use nqp;

INIT my int $uid     = +$*USER;
INIT my int $gid     = +$*GROUP;
INIT my str $dir-sep = $*SPEC.dir-sep;

my sub path-exists(str $path) {
    nqp::stat($path,nqp::const::STAT_EXISTS)
}
my sub path-is-directory(str $path) {
    nqp::stat($path,nqp::const::STAT_ISDIR)
}
my sub path-is-regular-file(str $path) {
    nqp::stat($path,nqp::const::STAT_ISREG)
}
my sub path-is-device(str $path) {
    nqp::stat($path,nqp::const::STAT_ISDEV)
}
my sub path-is-symbolic-link(str $path) {
    nqp::stat($path,nqp::const::STAT_ISLNK)
}

my sub path-created(str $path) {
    nqp::stat_time($path,nqp::const::STAT_CREATETIME)
}
my sub path-accessed(str $path) {
    nqp::stat_time($path,nqp::const::STAT_ACCESSTIME)
}
my sub path-modified(str $path) {
    nqp::stat_time($path,nqp::const::STAT_MODIFYTIME)
}
my sub path-meta-modified(str $path) {
    nqp::stat_time($path,nqp::const::STAT_CHANGETIME)
}

my sub path-uid(str $path) {
    nqp::stat($path,nqp::const::STAT_UID)
}
my sub path-gid(str $path) {
    nqp::stat($path,nqp::const::STAT_GID)
}

my sub path-inode(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_INODE)
}

my sub path-device-number(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_DEV)
}

my sub path-mode(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_MODE)
}

my sub path-hard-links(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_NLINKS)
}

my sub path-filesize(str $path) {
    nqp::stat($path,nqp::const::STAT_FILESIZE)
}
my sub path-is-empty(str $path) {
    nqp::iseq_i(nqp::stat($path,nqp::const::STAT_FILESIZE),0)
}

my sub path-block-size(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_BLOCKSIZE)
}
my sub path-blocks(str $path) {
    nqp::stat($path,nqp::const::STAT_PLATFORM_BLOCKS)
}

my sub path-is-readable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),256)
}
my sub path-is-writable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),128)
}
my sub path-is-executable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),64)
}

my sub path-is-group-readable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),32)
}
my sub path-is-group-writable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),16)
}
my sub path-is-group-executable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),8)
}

my sub path-is-world-readable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),4)
}
my sub path-is-world-writable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),2)
}
my sub path-is-world-executable(str $path) {
    nqp::bitand_i(nqp::stat($path,nqp::const::STAT_PLATFORM_MODE),1)
}

my sub path-is-owned-by-user(str $path) {
    nqp::iseq_i(nqp::stat($path,nqp::const::STAT_UID),$uid)
}
my sub path-is-owned-by-group(str $path) {
    nqp::iseq_i(nqp::stat($path,nqp::const::STAT_GID),$gid)
}

my sub path-is-git-repo(str $path) {
    my str $dotgit = $path ~ $dir-sep ~ ".git";
    nqp::stat($dotgit,nqp::const::STAT_EXISTS)
      && nqp::stat($dotgit,nqp::const::STAT_ISDIR)
}

my sub path-is-github-repo(str $path) {
    my str $dotgithub = $path ~ $dir-sep ~ ".github";
    nqp::stat($dotgithub,nqp::const::STAT_EXISTS)
      && nqp::stat($dotgithub,nqp::const::STAT_ISDIR)
}

my sub EXPORT(*@names) {
    Map.new: UNIT::{@names
      ?? @names.map: { '&' ~ $_ }
      !! UNIT::.keys.grep({
             .starts-with('&') && $_ ne '&EXPORT'
         })
    }:p
}

=begin pod

=head1 NAME

path-utils - low-level path introspection utility functions

=head1 SYNOPSIS

=begin code :lang<raku>

use path-utils;  # export all subs

use path-utils <path-exists>;  # only export sub path-exists

say path-exists($filename);  0 or 1

=end code

=head1 DESCRIPTION

path-utils provides a number of low-level path introspection utility
functions for those cases where you're interested in performance, rather
than functionality.

All subroutines take a (native) string as the only argument.

Note that these functions only return native C<int> and native C<num>
values, which can be used in conditions without any problems, just
don't expect them to be upgraded to C<Bool> values.

Also note that all functions (except C<path-exists>) expect the path
to exist.  An exception will be thrown if the path does not exist.
The reason for this is that in situations where you are already sure
a path exists, there is no point checking for its existence again if
you e.g. would like to know its size.

By default all utility functions are exported.  But you can limit this to
the functions you actually need by specifying the names in the C<use>
statement.

=head1 EXPORTED SUBROUTINES

In alphabetical order:

=head2 path-accessed

Returns number of seconds since epoch as a C<num> when path was
last accessed.

=head2 path-blocks

Returns the number of filesystem blocks allocated for this path.

=head2 path-block-size

Returns the preferred I/O size in bytes for interacting wuth the path.

=head2 path-created

Returns number of seconds since epoch as a C<num> when path was
created.

=head2 path-device-number

Returns the device number of the filesystem on which the path resides.

=head2 path-exists

Returns 1 if paths exists, 0 if not.

=head2 path-filesize

Returns the size of the path in bytes.

=head2 path-gid

Returns the numeric group id of the path.

=head2 path-hard-links

Returns the number of hard links to the path.

=head2 path-inode

Returns the inode of the path.

=head2 path-is-device

Returns 1 if path is a device, 0 if not.

=head2 path-is-directory

Returns 1 if path is a directory, 0 if not.

=head2 path-is-empty

Returns 1 if the path has a filesize of 0.

=head2 path-is-executable

Returns a non-zero integer value if path is executable by C<uid>.

=head2 path-is-github-repo

Returns 1 if path appears to be the top directory in a GitHub repository
(as recognized by having a C<.github> directory in it).

=head2 path-is-git-repo

Returns 1 if path appears to be the top directory in a Git repository
(as recognized by having a <.git> directory in it).

=head2 path-is-group-executable

Returns a non-zero integer value if path is executable by C<gid>.

=head2 path-is-group-readable

Returns a non-zero integer value if path is readable by C<gid>.

=head2 path-is-group-writable

Returns a non-zero integer value if path is writable by C<gid>.

=head2 path-is-owned-by-user

Returns a non-zero integer value if path is owned by the
current user.

=head2 path-is-owned-by-group

Returns a non-zero integer value if path is owned by the group
of the current user.

=head2 path-is-readable

Returns a non-zero integer value if path is readable by C<uid>.

=head2 path-is-regular-file

Returns 1 if path is a regular file, 0 if not.

=head2 path-is-symbolic-link

Returns 1 if path is a symbolic link, 0 if not.

=head2 path-is-world-executable

Returns a non-zero integer value if path is executable by any other user.

=head2 path-is-world-readable

Returns a non-zero integer value if path is readable by any other user.

=head2 path-is-world-writable

Returns a non-zero integer value if path is writable by any other user.

=head2 path-is-writable

Returns a non-zero integer value if path is writable by C<uid>.

=head2 path-meta-modified

Returns number of seconds since epoch as a C<num> when the meta
information of the path was last modified.

=head2 path-mode

Returns the numeric unix-style mode.

=head2 path-modified

Returns number of seconds since epoch as a C<num> when path was
last modified.

=head2 path-uid

Returns the numeric user id of the path.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/path-utils .
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
