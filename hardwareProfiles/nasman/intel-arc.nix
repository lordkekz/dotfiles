{
  inputs,
  outputs,
  personal-data,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # OpenCL support by Intel NEO for 8th gen and later
      # https://nixos.org/manual/nixos/stable/#sec-gpu-accel-opencl-intel
      intel-compute-runtime
      # VA-API support for Intel GPUs since 2015
      intel-media-driver
      # QSV (Quick Sync Video) support via OneVPL implementation since Intel ARC A
      vpl-gpu-rt
    ];
  };
}
