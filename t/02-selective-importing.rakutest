use Test;

my constant @subs = <
  path-accessed path-block-size path-blocks path-created path-device-number
  path-exists path-is-directory path-filesize path-gid path-hard-links
  path-has-setgid path-has-setuid path-inode path-is-device path-is-empty
  path-is-executable path-is-git-repo path-is-github-repo
  path-is-group-executable path-is-group-readable path-is-group-writable
  path-is-owned-by-group path-is-owned-by-user path-is-owner-executable
  path-is-owner-readable path-is-owner-writable path-is-readable
  path-is-regular-file path-is-sticky path-is-symbolic-link
  path-is-world-executable path-is-world-readable path-is-world-writable
  path-is-writable path-meta-modified path-mode path-modified path-uid
>;

plan @subs + 2;

my $code;
for @subs {
    $code ~= qq:!c:to/CODE/;
    {
        use path-utils '$_';
        ok MY::<&$_>:exists, "Did '$_' get exported?";
    }
    CODE
}

$code ~= qq:!c:to/CODE/;
{
    use path-utils <path-exists:alive>;
    ok MY::<&alive>:exists, "Did 'alive' get exported?";
    is MY::<&alive>.name, 'path-exists', 'Was the original name ok?';
}
CODE

$code.EVAL;

# vim: expandtab shiftwidth=4
