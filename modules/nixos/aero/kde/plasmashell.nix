{ pkgs, libplasma }:
pkgs.kdePackages.plasma-workspace.overrideAttrs (oldAttrs: {
  pname = "aero-plasmashell";
  cmakeFlags = oldAttrs.cmakeFlags ++ [
    "-DPlasma_DIR=${libplasma.dev}/lib/cmake/Plasma"
    "-DPlasmaQuick_DIR=${libplasma.dev}/lib/cmake/PlasmaQuick"
  ];
  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ libplasma ];
  excludeDependencies = [ "libplasma" ];
  outputs = [ "out" ];
  ninjaFlags = [
    "plasmashell"
    "startplasma-wayland"
    "klookandfeel"
    "kworkspace"
    "ksplashqml"
  ];
  installPhase = ''
    runHook preInstall
    ninja shell/install startkde/install libklookandfeel/install libkworkspace/install ksplash/install
    runHook postInstall
  '';
  passthru.providedSessions = [ ];
})
