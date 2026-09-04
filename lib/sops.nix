# sops paths shared by NixOS and Home Manager.
# Keeps the age key location in one place; the encrypted file itself
# is derived from the flake (self/secrets/common.yaml) on both sides.
{
  ageKeyFile = "/home/pexisgle/.config/sops/age/keys.txt";
}
