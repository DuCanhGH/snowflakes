{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.davinci;
in
{
  options.programs.davinci.enable = lib.mkEnableOption "Whether to install the DaVinci Resolve.";
  config = lib.mkIf cfg.enable {
    programs.ccache.packageNames = [ "davinci-resolve" ];
    environment.systemPackages = with pkgs; [
      davinci-resolve
      ffmpeg-full
    ];
  };
}
