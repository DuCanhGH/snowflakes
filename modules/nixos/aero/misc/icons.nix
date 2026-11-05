{
  pkgs,
  lib,
  mkAeroDerivation,
}:
mkAeroDerivation {
  pname = "aero-icons";
  src = pkgs.repos.aero-icons;
  postInstall = "ln -sf $out/share/icons/aero-drop $out/share/icons/default";
  meta = {
    description = "Aero Icons";
    platforms = lib.platforms.linux;
  };
}
