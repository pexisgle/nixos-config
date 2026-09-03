{ ... }:

{
  # opencodex refuses Codex config writes unless /tmp is root-owned with the
  # sticky bit (its coordinator trust check). NixOS normally keeps /tmp that
  # way, but if ownership ever drifts (manual chown, broken tmpfs mount),
  # every `ocx sync` fails with CodexUserIdentityRefusal. Enforce the expected
  # state declaratively so a reboot self-heals it.
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
  ];
}
