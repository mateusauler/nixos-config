{ lib, ... }:

{
  programs.btop = {
    enable = lib.mkDefault true;
    settings = {
      update_ms = 100;
      proc_sorting = "memory";
      proc_tree = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
    };
  };
}
