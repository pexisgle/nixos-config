# sops paths: the age key location is defined in flake.nix and passed through
# specialArgs (NixOS) / extraSpecialArgs (Home Manager).
{
  inputs,
  sopsPaths,
  ...
}:

{
  sops.age.keyFile = sopsPaths.ageKeyFile;
  sops.defaultSopsFile = "${inputs.self}/secrets/common.yaml";
  sops.useTmpfs = true;
}
