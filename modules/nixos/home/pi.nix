{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;
  pi-extensions = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "pi-extensions";
    version = "0.0.1";
    src = pkgs.repos.pi-extensions;
    nativeBuildInputs = with pkgs; [
      nodejs
      pnpm_11
      pnpmConfigHook
    ];
    pnpmInstallFlags = [ "--prod" ];
    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-GZh90NQcjRlE9iYpHJYDjtPdVGVK+DLysuN+bq14uQo=";
    };
    dontBuild = true;
    installPhase = ''
      cp -a . "$out"
    '';
  });
in
{
  programs.pi-coding-agent = lib.mkIf cfg.enable {
    extraPackages = with pkgs; [
      nodejs
      bubblewrap
      socat
      ripgrep
    ];
    models.providers."llama.cpp" = {
      baseUrl = lib.mkDefault "http://127.0.0.1:8080/v1";
      api = lib.mkDefault "openai-completions";
      apiKey = lib.mkDefault "none";
    };
    settings = {
      theme = "dark";
      extensions = [
        "${pi-extensions}/packages/sandbox"
      ];
    };
  };
  home.file.".pi/agent/mcp.json" = lib.mkIf cfg.enable {
    text = builtins.toJSON {
      mcpServers.svelte.url = "https://mcp.svelte.dev/mcp";
      mcpServers.exa.url = "https://mcp.exa.ai/mcp";
    };
  };
  home.file.".pi/agent/extensions/sandbox.json" = lib.mkIf cfg.enable {
    text = builtins.toJSON {
      enabled = true;
      network = {
        allowedDomains = [
          "npmjs.org"
          "*.npmjs.org"
          "registry.npmjs.org"
          "registry.yarnpkg.com"
          "pypi.org"
          "*.pypi.org"
          "github.com"
          "*.github.com"
          "api.github.com"
          "raw.githubusercontent.com"
        ];
        deniedDomains = [ ];
      };
      filesystem = {
        denyRead = [
          "~/.ssh"
          "~/.aws"
          "~/.gnupg"
          ".env"
          ".env.*"
        ];
        allowRead = [
          "."
          ".env.example"
        ];
        allowWrite = [
          "."
          "/tmp"
        ];
        denyWrite = [
          ".env"
          ".env.*"
          "*.pem"
          "*.key"
        ];
      };
    };
  };
}
