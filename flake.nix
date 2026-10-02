{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-rstudio.url = "github:NixOS/nixpkgs/d54020a6ac3211e9f4201631bdf67678818c0cdf";
    # The `follows` keyword in inputs is used for inheritance.
    # Here, `inputs.nixpkgs` of is kept consistent with the
    # `inputs.nixpkgs` of the current flake,
    # to avoid problems caused by different versions of nixpkgs.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aerothemeplasma = {
      url = "git+ssh://git@github.com/rustussy/aerothemeplasma";
      flake = false;
    };
    aero-libplasma = {
      url = "git+ssh://git@github.com/rustussy/aeroshell-libplasma";
      flake = false;
    };
    aero-workspace = {
      url = "git+ssh://git@github.com/rustussy/aeroshell-workspace";
      flake = false;
    };
    aero-kwin = {
      url = "git+ssh://git@github.com/rustussy/aeroshell-kwin-components";
      flake = false;
    };
    aero-smod = {
      url = "git+ssh://git@github.com/rustussy/aeroshell-smod";
      flake = false;
    };
    uac-polkit-agent = {
      url = "git+ssh://git@github.com/rustussy/uac-polkit-agent";
      flake = false;
    };
    plymouth-vista = {
      url = "git+ssh://git@github.com/rustussy/plymouth-vista";
      flake = false;
    };
    plasma-video-wallpaper = {
      url = "git+ssh://git@github.com/rustussy/plasma-video-wallpaper";
      flake = false;
    };
    pi-extensions = {
      url = "git+ssh://git@github.com/DuCanhGH/pi-extensions";
      flake = false;
    };
    secrets = {
      url = "git+ssh://git@github.com/DuCanhGH/nix-secrets.git";
      flake = false;
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      lanzaboote,
      agenix,
      plasma-manager,
      ...
    }:
    let
      specialArgs = { inherit inputs; };
      home-manager-options = {
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
      };
    in
    {
      darwinConfigurations.duckintosh = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;
        modules = [
          home-manager.darwinModules.home-manager
          ./systems/duckintosh/configuration.nix
          { home-manager.extraSpecialArgs = specialArgs; }
        ];
      };
      nixosConfigurations.pneuma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          ./systems/pneuma/configuration.nix
          home-manager-options
        ];
      };
      nixosConfigurations.ousia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          ./systems/ousia/configuration.nix
          home-manager-options
        ];
      };
    };
}
