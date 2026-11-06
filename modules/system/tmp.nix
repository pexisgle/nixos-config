{ ... }:

{
  # opencodex refuses to write Codex config unless /tmp is 1777 root:root.
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
  ];
}
