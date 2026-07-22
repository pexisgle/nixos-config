{ inputs, ... }:

{
  sops.age.keyFile = "/home/pexisgle/.config/sops/age/keys.txt";
  sops.defaultSopsFile = "${inputs.self}/secrets/common.yaml";
  sops.useTmpfs = true;
}
