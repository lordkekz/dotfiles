{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (inputs) microvm;
in {
  imports = [microvm.nixosModules.host];
}
