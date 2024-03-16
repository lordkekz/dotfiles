args @ {
  # Flake's inputs and outputs
  inputs,
  outputs,
  # Targeted system
  system,
  # Nixpkgs instances for targeted system
  pkgs-stable,
  pkgs-unstable,
  pkgs,
}: let
  longDescription = ''
    Sather-K ist eine objektorientierte, imperative Sprache, welche überwiegend in der Lehre eingesetzt wird. Sie wurde in Karlsruhe aus der Sprache Sather entwickelt, welche Anfang der Neunziger in der Universität von Kalifornien (Berkley) entstanden ist. Beide Sprachen werden stark von Konzepten der Sprache Eiffel beeinflußt.

    Am Lehrstuhl für Software-Engineering und Programmiersprachen Halle wurden in mehreren Projektarbeiten und einer Diplomarbeit ein Übersetzer für Sather-K entwickelt. Dieser übersetzt Sather-K-Programme in die Zwischensprache des Microsoft .NET-Frameworks.

    Neben klassischen objektorientierten und imperativen Sprachbestandteilen zeichnet sich Sather-K durch eine Reihe von speziellen Konstrukten aus, die in dieser Form in anderen Sprachen nur zum Teil zu finden sind:

    - Eine Unterteilung des Typsystems in monomorphe und polymorphe Typen
    - Die Iteration von Enumerationsobjekten durch Ströme (vergleichbar mit Generatoren oder yield-Anweisungen in anderen Sprachen)
    - Methoden als first-class-Objekte in Form gebundener Methoden
  '';

  baseMeta = with pkgs.lib; {
    homepage = "https://swt.informatik.uni-halle.de/software/satherkhalle/";
    downloadPage = "https://swt.informatik.uni-halle.de/software/satherkhalle/download/";
    license = licenses.gpl3;
    mainProgram = "satk";
    platforms = platforms.all;
    maintainers = [];
  };

  src = pkgs.fetchzip {
    # Uni website gives a 502 for this URL; probably because they're replacing the software.
    # url = "https://swt2.informatik.uni-halle.de/downloads//Software/satk_0.3.5-347.zip";
    url = "file:///${inputs.self}/assets/satk_0.3.5-347.zip";
    hash = "sha256-Q9HeSkBRTrd5Xfp8YuGvd30f9HMvCMe6XcoKu2wBOKk=";
  };
in rec {
  mono-wrapper = pkgs.writeShellApplication {
    name = "mono";
    meta.description = "A wrapper script for the old mono 4.8.1 package. Includes a workaround for $TERM variable.";

    runtimeInputs = [pkgs.mono4];

    text = ''
      # Workaround for a bug in Mono ILASM:
      # https://stackoverflow.com/questions/49242075/mono-bug-magic-number-is-wrong-542
      export TERM=xterm

      ${pkgs.mono4}/bin/mono "$@"
    '';
  };

  satk-base = pkgs.stdenv.mkDerivation rec {
    name = "satk-compiler-halle";
    version = "0.3.5-347";
    meta = with pkgs.lib;
      baseMeta
      // {
        description = "Sather-K Compiler Halle (base binary)";
        inherit longDescription;
      };

    inherit src system;

    nativeBuildInputs = [pkgs.gcc48];
    buildInputs = [pkgs.gmp];
    runtimeInputs = [mono-wrapper];

    buildPhase = ''
      cd src && make && cd ..
    '';
    installPhase = ''
      mkdir -p "$out/bin"
      cp -r bin/satk "$out/bin"

      mkdir -p "$out/lib"
      cp -r lib/* "$out/lib"

      mkdir -p "$out/examples"
      cp -r examples/* "$out/examples"
    '';
  };

  satk-get-examples = pkgs.writeShellApplication {
    name = "satk-get-examples";
    meta = with pkgs.lib;
      baseMeta
      // {
        description = "A helper to get you the example files for satk.";
        mainProgram = "satk-get-examples";
      };

    runtimeInputs = [satk-base];

    text = ''
      printf "The example files are located in:\n${satk-base}/examples/\n"
      ${pkgs.findutils}/bin/find ${satk-base}/examples/*
    '';
  };

  satk-wrapper = pkgs.writeShellApplication {
    name = "satk";
    meta = with pkgs.lib;
      baseMeta
      // {
        description = "Sather-K Compiler Halle (wrapper script)";
        longDescription = "This is a wrapper script for Sather-K Compiler Halle.\n" ++ longDescription;
      };

    runtimeInputs = [satk-base];

    text = ''
      # Set defaults for Sather-K's environment variables based on our derivation
      : "${"\${SAKLIBPATH:=${satk-base}/lib}"}"
      : "${"\${SAKCILCOMP:=${pkgs.mono4}/bin/ilasm}"}"
      export SAKLIBPATH SAKCILCOMP

      # Workaround for a bug in Mono ILASM:
      # https://stackoverflow.com/questions/49242075/mono-bug-magic-number-is-wrong-542
      export TERM=xterm

      satk "$@"
    '';
  };

  satk-full = pkgs.symlinkJoin {
    name = "satk-full";
    meta = with pkgs.lib;
      baseMeta
      // {
        description = "Sather-K Compiler Halle (full)";
        longDescription = "" "
          A meta-package consisting of:
          - A wrapper script for mono 4.8.1
          - A wrapper script for satk
          - The satk-get-examples helper
          " "" ++ longDescription;
      };

    paths = [mono-wrapper satk-wrapper satk-get-examples];
    postBuild = "echo links added";
  };
}
