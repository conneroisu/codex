{
  description = "Development Nix flake for OpenAI Codex CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      node = pkgs.nodejs_22;
    in rec {
      packages = {
        codex-cli = pkgs.buildNpmPackage {
          pname = "codex-cli";
          version = "0.1.0";
          src = ./codex-cli;
          npmDepsHash = "sha256-UkvkaM7tvVlio0st8UA45x8wQ+q423BTzshsmdmmO2o=";
          nodejs = node;
          npmInstallFlags = ["--frozen-lockfile"];
          meta = with pkgs.lib; {
            description = "OpenAI Codex command‑line interface";
            license = licenses.asl20;
            homepage = "https://github.com/openai/codex";
          };
        };
      };
      defaultPackage = packages.codex-cli;
      devShell = pkgs.mkShell {
        name = "codex-cli-dev";
        buildInputs = [
          node
        ];
        shellHook = ''
          echo "Entering development shell for codex-cli"
          cd codex-cli
          npm ci
          npm run build
          export PATH=$PWD/node_modules/.bin:$PATH
          alias codex="node $PWD/dist/cli.js"
        '';
      };
      apps = {
        codex = {
          type = "app";
          program = "${packages.codex-cli}/bin/codex";
        };
      };
    });
}
