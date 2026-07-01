{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host sol" = {
        HostName = "sol.cc.uec.ac.jp";
        User = "s2611114";
      };
    };
  };
}
