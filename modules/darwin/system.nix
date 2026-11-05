{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages =
    (import ../shared/packages.nix { inherit pkgs; })
    ++ (with pkgs; [
      firefox-unwrapped
      gnupg
      inputs.agenix.packages.aarch64-darwin.default
    ]);

  environment.shells = [ pkgs.fish ];

  programs.fish.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  nix = {
    # Disabled. Re-enable to use the following settings:
    enable = false;
    # settings.auto-optimise-store = true;
    # optimise.automatic = true;
    # settings.experimental-features = [ "nix-command" "flakes" ];
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 1w";
    # };
  };

  system.stateVersion = 6;
  system.primaryUser = "ducanh";
  system.activationScripts.extraActivation.text = ''
    ln -sf "${pkgs.jdk21}/Library/Java/JavaVirtualMachines/zulu-21.jdk" "/Library/Java/JavaVirtualMachines/"
  '';
}
