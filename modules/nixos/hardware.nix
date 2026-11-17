{ config, lib, pkgs, ... }:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    plymouth.enable = true;
    # Enable "Silent boot"
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    branch = lib.mkDefault "production";
    nvidiaSettings = true;
  };
}
