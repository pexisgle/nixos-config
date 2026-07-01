{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      sol = {
        hostname = "sol.cc.uec.ac.jp";
        user = "s2611114";
      };
    };
  };
}
