{
  pkgs,
  system,
  ...
}: let
  satk-bin = pkgs.stdenv.mkDerivation rec {
    name = "satk-bin";
    version = "0.3.5-347";
    src = pkgs.fetchzip {
      url = "https://swt2.informatik.uni-halle.de/downloads//Software/satk_0.3.5-347.zip";
      hash = "sha256-Q9HeSkBRTrd5Xfp8YuGvd30f9HMvCMe6XcoKu2wBOKk=";
    };
    inherit system;

    nativeBuildInputs = [pkgs.gcc48];
    buildInputs = [pkgs.gmp];
    runtimeInputs = [pkgs.mono4];

    buildPhase = ''
      cd src && make && cd ..
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp bin/satk $out/bin

      mkdir -p $out/lib
      cp lib/* $out/lib

      ls -lar $out
    '';
  };

  wrapperScript = pkgs.writeShellApplication {
    name = "satk";

    runtimeInputs = [satk-bin];

    text = ''
      # Set defaults for Sather-K's environment variables based on our derivation
      : "${"\${SAKLIBPATH:=${satk-bin}/lib}"}"
      : "${"\${SAKCILCOMP:=${pkgs.mono4}/bin/ilasm}"}"
      export SAKLIBPATH SAKCILCOMP

      # Workaround for a bug in Mono ILASM:
      # https://stackoverflow.com/questions/49242075/mono-bug-magic-number-is-wrong-542
      export TERM=xterm

      satk "$@"
    '';
  };
in
  wrapperScript
