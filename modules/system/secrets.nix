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
