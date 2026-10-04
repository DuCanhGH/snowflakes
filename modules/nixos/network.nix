{ config, ... }:
{
  services = {
    resolved.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  # Force tailscaled to use nftables (Critical for clean nftables-only systems).
  # This avoids the "iptables-compat" translation layer issues.
  # https://wiki.nixos.org/wiki/Tailscale#Native_nftables_Support_(Modern_Setup)
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      # Always allow traffic from your Tailscale network
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      # Open ports in the firewall.
      # allowedUDPPorts = [ ... ];
      allowedTCPPorts = [ 3000 ];
    };
  };
}
