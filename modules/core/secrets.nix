# sops paths: key location is shared with Home Manager via lib/sops.nix.
{
  inputs,
  sopsPaths ? import ../../lib/sops.nix,
  ...
}:

{
  sops.age.keyFile = sopsPaths.ageKeyFile;
  sops.defaultSopsFile = "${inputs.self}/secrets/common.yaml";
  sops.useTmpfs = true;
}
