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
      rev = "867f54bd5cc233ccf94b5bf4e04958b39241a8a8";
      hash = "sha256-z4CO3zQT8AfgpDe9i+e800rf9k7UnD70mU+2wdNoxjg=";
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
