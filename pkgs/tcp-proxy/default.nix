{
  pkgs,
  inputs,
  ...
}:
(pkgs.callPackage inputs.naersk {}).buildPackage {src = ./.;}
