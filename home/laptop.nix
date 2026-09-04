# Thin per-host entry: both hosts share home/common.nix today.
# Keep this file so future laptop-only home settings have a home.
{ ... }:

{
  imports = [
    ./common.nix
  ];
}
