{
  pkgs,
  lib,
  mkAeroDerivation,
}:
mkAeroDerivation {
  pname = "aero-sounds";
  src = pkgs.repos.aero-sounds;
  meta = {
    description = "Aero Sounds";
    platforms = lib.platforms.linux;
  };
}
