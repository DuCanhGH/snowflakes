{ lib, config, ... }:
let
  cfg = config.programs.opencode;
in
{
  programs.opencode = lib.mkIf cfg.enable {
    settings = {
      lsp = { };
      mcp.svelte = {
        type = "remote";
        url = "https://mcp.svelte.dev/mcp";
      };
      permission = {
        "*" = "ask";
        bash = "ask";
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        grep = "ask";
        glob = "ask";
        lsp = "allow";
        edit = "allow";
        skill = "allow";
        todowrite = "allow";
        webfetch = "allow";
        websearch = "allow";
        question = "allow";
      };
      provider = {
        "llama.cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-server (local)";
          options.baseURL = lib.mkDefault "http://127.0.0.1:8080/v1";
        };
      };
    };
  };
}
