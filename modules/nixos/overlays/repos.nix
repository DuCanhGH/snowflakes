{ inputs }:
final: prev: {
  repos = {
    inherit (inputs)
      aerothemeplasma
      aero-libplasma
      aero-workspace
      aero-kwin
      aero-smod
      uac-polkit-agent
      plymouth-vista
      plasma-video-wallpaper
      pi-extensions
      ;
    aero-icons = prev.fetchFromGitLab {
      domain = "gitgud.io";
      owner = "aeroshell";
      repo = "atp/aerothemeplasma-icons";
      rev = "0100536bb0fb4b731b6cf776f3bc6dc5d3c74bfc";
      hash = "sha256-5tB52/IYB4oz3Zn3TPcSWLfdCLvYLRqxshbGzZyPHzE=";
    };
    aero-sounds = prev.fetchFromGitLab {
      domain = "gitgud.io";
      owner = "aeroshell";
      repo = "atp/aerothemeplasma-sounds";
      rev = "55d2f5fd15f53cccbbb13388941b930442db1159";
      hash = "sha256-z73owMl2+mAQJKGgjuJAmPIYOYuoVug0nWZ3WqWY0DY=";
    };
  };
}
