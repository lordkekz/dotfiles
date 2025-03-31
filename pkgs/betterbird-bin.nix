{
  stdenv,
  lib,
  fetchurl,
  alsaLib,
  openssl,
  zlib,
  pulseaudio,
  autoPatchelfHook,
  betterbird-language ? "de-DE",
}:
stdenv.mkDerivation rec {
  pname = "betterbird-bin";
  version = "128.8.0esr-bb23";

  src = fetchurl {
    url = "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${version}.${betterbird-language}.linux-x86_64.tar.bz2";
    hash = "";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsaLib
    openssl
    zlib
    pulseaudio
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    ls -lah .
    install -m755 -D studio-link-standalone-v${version} $out/bin/studio-link
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://betterbird.eu";
    description = "Betterbird thingy";
    platforms = platforms.linux-x86_64;
  };
}
