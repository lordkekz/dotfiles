{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  #scripts.hello.exec = ''
  #  echo hello from $GREET
  #'';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  #languages.python.enable = true;
  #languages.python.version = "3.12.5";

  languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    # Misc
    shellcheck.enable = true;
    trim-trailing-whitespace.enable = true;
    end-of-file-fixer.enable = true;

    # Nix code
    alejandra.enable = true;
    #flake-checker.enable = true;
    #deadnix.enable = true;
    #statix.enable = true;

    # Python code
    black.enable = true;
  };

  packages = [
    pkgs.agenix-rekey
    pkgs.deploy-rs
  ];

  # See full reference at https://devenv.sh/reference/options/
}
