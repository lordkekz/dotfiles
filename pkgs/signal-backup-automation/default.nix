{
  pkgs,
  inputs,
  ...
}:
pkgs.writeShellApplication {
  name = "signal-backup-automation";
  text = builtins.readFile ./signalbackup.bash;
  runtimeInputs = with pkgs; [
    signalbackup-tools
    coreutils
    gnused
    findutils
  ];
  meta = {
    homepage = "https://heinrich-preiser.de/posts/signalbackup-automation";
    mainProgram = "signal-backup-automation";
  };
}
