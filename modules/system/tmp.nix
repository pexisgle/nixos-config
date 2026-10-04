{ ... }:

{
  # opencodex refuses Codex config writes unless /tmp is root-owned with the
  # sticky bit ("The system temporary directory lacks sticky world write/search
  # permissions"). NixOS normally keeps /tmp that way, but if ownership ever
  # drifts (manual chown, broken tmpfs mount), opencodex stops working.
  # Enforce the expected state declaratively so a reboot self-heals it.
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
  ];
}
