# This is a naughty module using NQP
use nqp;

INIT quietly my int $uid = +$*USER  // 0;
INIT quietly my int $gid = +$*GROUP // 0;
INIT my str $dir-sep = $*SPEC.dir-sep;

my constant LFLF   = 2570;                # "\n\n" as a 16bit uint
my constant BIT16 =
  nqp::const::BINARY_SIZE_16_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;
my constant BIT32 =
  nqp::const::BINARY_SIZE_32_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;
my constant BIT64 =
  nqp::const::BINARY_SIZE_64_BIT +| nqp::const::BINARY_ENDIAN_LITTLE;

# Turn a Block into a WhateverCode, which guarantees here are no 
# phasers that need to be taken into account, and there a no
# return statements
my sub WC($block is raw) {  # UNCOVERABLE
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

my constant SQLITE1 = 0x66206574694c5153;  # "SQLite f" as 64bit int
my constant SQLITE2 = 0x00332074616d726f;  # "ormat 3\0" as 64bit int
my sub path-is-sqlite(str $path) {
    nqp::iseq_i(nqp::filereadable($path),1) && do {
        my $fh  := nqp::open($path, 'r');
        my $buf := nqp::create(buf8.^pun);
        nqp::readfh($fh,$buf,16);
        nqp::closefh($fh);

        nqp::iseq_i(nqp::elems($buf),16)
          && nqp::iseq_i(nqp::readuint($buf,0,BIT64), SQLITE1)
          && nqp::iseq_i(nqp::readuint($buf,8,BIT64), SQLITE2)
    }
}

my constant MOARVM = 724320148219055949;  # "MOARVM\r\n" as a 64bit int
my sub path-is-moarvm(str $path) {
    nqp::iseq_i(nqp::filereadable($path),1) && do {
        my $fh  := nqp::open($path, 'r');
        my $buf := nqp::create(buf8.^pun);
        nqp::readfh($fh, $buf, 16384);
        nqp::closefh($fh);

        # A pure MoarVM bytecode file
        if nqp::isge_i(nqp::elems($buf),8)
          && nqp::iseq_i(nqp::readuint($buf,0,BIT64), MOARVM) {  # UNCOVERABLE
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
  @table[$_] = 1 for flat "\t\b\o33\o14".ords, 32..126, 128..255;  # UNCOVERABLE
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

my sub path-is-owned-by-user(str $path) {
    nqp::iseq_i(nqp::stat($path,nqp::const::STAT_UID),$uid)
}
my sub path-is-owned-by-group(str $path) {
    nqp::iseq_i(nqp::stat($path,nqp::const::STAT_GID),$gid)
}

my sub path-git-repo(str $path) {
    my str @parts = nqp::split($dir-sep, $path);
    my str $repo;
    nqp::while(
      nqp::elems(@parts)
        && nqp::not_i(path-is-git-repo(
          ($repo = nqp::join($dir-sep, @parts)),
        )),
      nqp::pop_s(@parts)
    );

    nqp::elems(@parts) ?? $repo !! ""
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

# vim: expandtab shiftwidth=4
