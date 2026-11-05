{
  pkgs,
  lib,
  mkAeroDerivation,
  plasmashell,
}:
mkAeroDerivation {
  pname = "aerothemeplasma";
  src = pkgs.repos.aerothemeplasma;
  outputs = [
    "out"
    "dev"
  ];
  postPatch = ''
    substituteInPlace $(find plasma -type f -name '*.qml' -o -name '*.js') \
      --replace-quiet "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core" \
      --replace-quiet "import org.kde.plasma.plasmoid" "import io.gitgud.wackyideas.plasma.plasmoid"
    substituteInPlace plasma/plasmoids/src/sevenstart_src/CMakeLists.txt --replace-fail "add_subdirectory(src)" "find_package(PlasmaQuick)
      add_subdirectory(src)"
    substituteInPlace plasma/plasmoids/src/sevenstart_src/src/CMakeLists.txt \
      --replace-fail "Plasma" "Plasma::Plasma" \
      --replace-fail "/usr/include/Plasma" "Plasma"
    mkdir -p $dev
    cp -a . $dev
  '';
  postFixup = ''
    substituteInPlace $out/bin/startatp-wayland \
      --replace-fail "$out/libexec/plasma-dbus-run-session-if-needed" "${plasmashell}/libexec/plasma-dbus-run-session-if-needed" \
      --replace-fail "$out/bin/startplasma-wayland" "${plasmashell}/bin/startplasma-wayland"
  '';
  installPhase = ''
    runHook preInstall
    ninja install
    echo -e "[General]\ntheme=Windows7Aero" > $out/share/Kvantum/kvantum.kvconfig
    runHook postInstall
  '';
  passthru.providedSessions = [ "aerothemeplasma" ];
  meta = {
    description = "Aero for Plasma";
    platforms = lib.platforms.linux;
  };
}
