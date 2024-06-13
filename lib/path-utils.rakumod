# This is a naughty module using NQP
use nqp;

INIT quietly my int $uid = +$*USER;
INIT quietly my int $gid = +$*GROUP;
INIT my str $dir-sep = $*SPEC.dir-sep;

my constant LFLF   = 2570;                # "\n\n" as a 16bit uint
my constant MOARVM = 724320148219055949;  # "MOARVM\r\n" as a 64bit uint
my constant BIT16 =
  nqp::const::BINARY_SIZE_16_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;
my constant BIT64 =
  nqp::const::BINARY_SIZE_64_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;

# Turn a Block into a WhateverCode, which guarantees here are no 
# phasers that need to be taken into account, and there a no
# return statements
my sub WC($block is raw) {
    my $wc := nqp::create(WhateverCode);
    nqp::bindattr(
      $wc,Code,'$!do',nqp::getattr($block,Code,'$!do')
    );
    nqp::bindattr(
      $wc,Code,'$!signature',nqp::getattr($block,Code,'$!signature')
    );
    nqp::bindattr(
      $wc,Code,'@!compstuff',nqp::getattr($block,Code,'@!compstuff')
    );
    $wc
}

my sub path-is-moarvm(str $path) {
    nqp::iseq_i(nqp::filereadable($path),1) && do {
        my $fh  := nqp::open($path, 'r');
        my $buf := nqp::create(buf8.^pun);
        nqp::readfh($fh, $buf, 16384);
        nqp::closefh($fh);

        # A pure MoarVM bytecode file
        if nqp::isge_i(nqp::elems($buf),8)
          && nqp::iseq_i(nqp::readuint($buf,0,BIT64), MOARVM) {
            1
        }

        # Possibly a module precomp file
        else {
            my int $last = nqp::elems($buf) - 8;
            my int $offset;

            # Find the first \n\n
            nqp::while(
              nqp::isle_i($offset,$last)
                && nqp::isne_i(nqp::readuint($buf,$offset++,BIT16), LFLF),
              nqp::null
            );

            # Found \n\n followed by MoarVM magic number
            nqp::isle_i($offset, $last)
              && nqp::iseq_i(nqp::readuint($buf,$offset + 1,BIT64), MOARVM)
        }
    }
}

my constant PDF = 1178882085;  # "%PDF" as a 32bit uint
my constant BIT32 =
  nqp::const::BINARY_SIZE_32_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;

my sub path-is-pdf(str $path) {
    nqp::iseq_i(nqp::filereadable($path),1) && do {
        my $fh  := nqp::open($path, 'r');
        my $buf := nqp::create(buf8.^pun);
        nqp::readfh($fh, $buf, 4);
        nqp::closefh($fh);
        nqp::isge_i(nqp::elems($buf),4)
          && nqp::iseq_i(nqp::readuint($buf,0,BIT32), PDF)
    }
}

my constant PRINTABLE = do {
  my int @table;
  @table[$_] = 1 for flat "\t\b\o33\o14".ords, 32..126, 128..255;
  @table
}
my sub path-is-text(str $path) {
    nqp::iseq_i(nqp::filereadable($path),1) && do {
        my $fh  := nqp::open($path, 'r');
        my $buf := nqp::create(buf8.^pun);
        nqp::readfh($fh, $buf, 4096);
        nqp::closefh($fh);

        my int $limit = nqp::elems($buf);
        my int $printable;
        my int $unprintable;
        my int $i = -1;

        # Algorithm shamelessly copied from Jonathan Worthington's
        # Data::TextOrBinary module, converted to NQP ops for speed
        nqp::while(
          nqp::islt_i(++$i,$limit),
          nqp::stmts(
            nqp::if(
              (my int $check = nqp::atpos_i($buf,$i)),
              nqp::if(   # not a NULL byte, check
                nqp::iseq_i($check,13),
                nqp::if(
                  nqp::isne_i(nqp::atpos_i($buf,++$i),10),
                  (return 0),             # \r not followed by \n hints binary
                ),
                nqp::if(
                  nqp::isne_i($check,10), # Ignore lone \n
                  nqp::if(
                    nqp::atpos_i(PRINTABLE,$check),
                    ++$printable,
                    ++$unprintable
                  )
                )
              ),
              (return 0) # NULL byte, so binary.
            )
          )
        );
        nqp::isge_i(nqp::bitshiftr_i($printable,7),$unprintable)
    }
}

my constant &path-exists = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_EXISTS)
}
my constant &path-is-directory = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_ISDIR)
}
my constant &path-is-regular-file = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_ISREG)
}
my constant &path-is-device = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_ISDEV)
}
my constant &path-is-symbolic-link = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_ISLNK)
}

my constant &path-created = WC -> str $_ {
    nqp::stat_time($_,nqp::const::STAT_CREATETIME)
}
my constant &path-accessed = WC -> str $_ {
    nqp::stat_time($_,nqp::const::STAT_ACCESSTIME)
}
my constant &path-modified = WC -> str $_ {
    nqp::stat_time($_,nqp::const::STAT_MODIFYTIME)
}
my constant &path-meta-modified = WC -> str $_ {
    nqp::stat_time($_,nqp::const::STAT_CHANGETIME)
}

my constant &path-uid = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_UID)
}
my constant &path-gid = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_GID)
}

my constant &path-inode = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_INODE)
}

my constant &path-device-number = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_DEV)
}

my constant &path-mode = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_MODE)
}

my constant &path-hard-links = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_NLINKS)
}

my constant &path-filesize = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_FILESIZE)
}
my constant &path-is-empty = WC -> str $_ {
    nqp::iseq_i(nqp::stat($_,nqp::const::STAT_FILESIZE),0)
}

my constant &path-block-size = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_BLOCKSIZE)
}
my constant &path-blocks = WC -> str $_ {
    nqp::stat($_,nqp::const::STAT_PLATFORM_BLOCKS)
}

my constant &path-is-readable = WC -> str $_ {
    nqp::filereadable($_)
}
my constant &path-is-writable = WC -> str $_ {
    nqp::filewritable($_)
}
my constant &path-is-executable = WC -> str $_ {
    nqp::fileexecutable($_)
}

my constant &path-has-setuid = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),2048)
}
my constant &path-has-setgid = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),1024)
}
my constant &path-is-sticky = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),512)
}

my constant &path-is-owner-readable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),256)
}
my constant &path-is-owner-writable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),128)
}
my constant &path-is-owner-executable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),64)
}

my constant &path-is-group-readable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),32)
}
my constant &path-is-group-writable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),16)
}
my constant &path-is-group-executable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),8)
}

my constant &path-is-world-readable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),4)
}
my constant &path-is-world-writable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),2)
}
my constant &path-is-world-executable = WC -> str $_ {
    nqp::bitand_i(nqp::stat($_,nqp::const::STAT_PLATFORM_MODE),1)
}

my constant &path-is-owned-by-user = WC -> str $_ {
    nqp::iseq_i(nqp::stat($_,nqp::const::STAT_UID),$uid)
}
my constant &path-is-owned-by-group = WC -> str $_ {
    nqp::iseq_i(nqp::stat($_,nqp::const::STAT_GID),$gid)
}

my constant &path-is-git-repo = WC -> str $_ {
    my str $dotgit = $_ ~ $dir-sep ~ ".git";
    nqp::stat($dotgit,nqp::const::STAT_EXISTS)
      && nqp::stat($dotgit,nqp::const::STAT_ISDIR)
}

my constant &path-is-github-repo = WC -> str $_ {
    my str $dotgithub = $_ ~ $dir-sep ~ ".github";
    nqp::stat($dotgithub,nqp::const::STAT_EXISTS)
      && nqp::stat($dotgithub,nqp::const::STAT_ISDIR)
}

my sub EXPORT(*@names) {
    Map.new: @names
      ?? @names.map: {
             if UNIT::{"&$_"}:exists {
                 UNIT::{"&$_"}:p
             }
             else {
                 my ($in,$out) = .split(':', 2);
                 if $out && UNIT::{"&$in"} -> &code {
                     Pair.new: "&$out", &code
                 }
             }
         }
      !! UNIT::.grep: {
             .key.starts-with('&') && .key ne '&EXPORT'
         }
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

=head1 SELECTIVE IMPORTING

=begin code :lang<raku>

use path-utils <path-exists>;  # only export sub path-exists

=end code

By default all utility functions are exported.  But you can limit this to
the functions you actually need by specifying the names in the C<use>
statement.

To prevent name collisions and/or import any subroutine with a more
memorable name, one can use the "original-name:known-as" syntax.  A
semi-colon in a specified string indicates the name by which the subroutine
is known in this distribution, followed by the name with which it will be
known in the lexical context in which the C<use> command is executed.

=begin code :lang<raku>

use path-utils <path-exists:alive>;  # export "path-exists" as "alive"

say alive "/etc/passwd";  # 1 if on Unixy, 0 on Windows

=end code

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

=head2 path-has-setgid

The path has the SETGID bit set in its attributes.

=head2 path-inode

Returns the inode of the path.

=head2 path-is-device

Returns 1 if path is a device, 0 if not.

=head2 path-is-directory

Returns 1 if path is a directory, 0 if not.

=head2 path-is-empty

Returns 1 if the path has a filesize of 0.

=head2 path-is-executable

Returns a non-zero integer value if path is executable by the current user.

=head2 path-is-github-repo

Returns 1 if path appears to be the top directory in a GitHub repository
(as recognized by having a C<.github> directory in it).

=head2 path-is-git-repo

Returns 1 if path appears to be the top directory in a Git repository
(as recognized by having a <.git> directory in it).

=head2 path-is-group-executable

Returns a non-zero integer value if path is executable by members of the
group of the path.

=head2 path-is-group-readable

Returns a non-zero integer value if path is readable by members of the
group of the path.

=head2 path-is-group-writable

Returns a non-zero integer value if path is writable by members of the
group of the path.

=head2 path-is-moarvm

Returns 1 if path is a C<MoarVM> bytecode file (either from core, or
from a precompiled module file), 0 if not.

=head2 path-is-owned-by-user

Returns a non-zero integer value if path is owned by the
current user.

=head2 path-is-owned-by-group

Returns a non-zero integer value if path is owned by the group
of the current user.

=head2 path-is-owner-executable

Returns a non-zero integer value if path is executable by the owner of
the path.

=head2 path-is-owner-readable

Returns a non-zero integer value if path is readable by the owner of
the path.

=head2 path-is-owner-writable

Returns a non-zero integer value if path is writable by the owner of
the path.

=head2 path-is-pdf

Returns 1 if path looks a C<PDF> file, judging by its magic number,
0 if not.

=head2 path-is-readable

Returns a non-zero integer value if path is readable by the current user.

=head2 path-is-regular-file

Returns 1 if path is a regular file, 0 if not.

=head2 path-is-sticky

The path has the STICKY bit set in its attributes.

=head2 path-is-symbolic-link

Returns 1 if path is a symbolic link, 0 if not.

=head2 path-is-text

Returns 1 if path looks like it contains text, 0 if not.

=head2 path-is-world-executable

Returns a non-zero integer value if path is executable by anybody.

=head2 path-is-world-readable

Returns a non-zero integer value if path is readable by anybody.

=head2 path-is-world-writable

Returns a non-zero integer value if path is writable by any body.

=head2 path-is-writable

Returns a non-zero integer value if path is writable by the current user.

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

Copyright 2022, 2023, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
