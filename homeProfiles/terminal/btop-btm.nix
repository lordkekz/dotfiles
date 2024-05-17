# System monitors such as btop or bottom
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  # My system monitor of choice
  programs.btop = {
    enable = true;
    settings = {
      update_ms = 1000; # Docs recommend above 2000
      theme_background = false;
      proc_filter_kernel = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "user"; # Also try "guest"
      zfs_arc_cached = true;
      # Disk display
      only_physical = true;
      use_fstab = false;
      zfs_hide_datasets = true;
      show_io_stat = true;
    };
  };

  # Another nice system monitor (command: btm)
  programs.bottom.enable = true;
}
