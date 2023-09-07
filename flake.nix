{
  description = "Test environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zunit = {
      url = "github:zunit-zsh/zunit";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
          with builtins;
          let
            pkgs = import nixpkgs { inherit system; };
          in
          rec
          {
            packages = {
              revolver = pkgs.stdenvNoCC.mkDerivation rec {
                name = "revolver";
                ver = "0.2.0";
                src = pkgs.fetchFromGitHub {
                  owner = "molovo";
                  repo = "revolver";
                  rev = "6424e6cb14da38dc5d7760573eb6ecb2438e9661";
                  sha256 = "sha256-2onqjtPIsgiEJj00oP5xXGkPZGQpGPVwcBOhmicqKcs=";
                };
                dontBuild = true;
                installPhase = ''
                  runHook preInstall
                  mkdir -p $out/bin
                  cp revolver $out/bin/
                  mkdir -p $out/share/zsh/site-functions
                  cp revolver.zsh-completion $out/share/zsh/site-functions/_revolver
                  runHook postInstall
                '';
              };
              zunit = pkgs.stdenvNoCC.mkDerivation rec {
                name = "zunit";
                ver = "0.8.2";
                src = pkgs.fetchFromGitHub {
                  owner = "zunit-zsh";
                  repo = "zunit";
                  rev = "b86c006f62db138a119e9be3a4b41e28876889b2";
                  sha256 = "sha256-kW+8EBObknsyDwvy6XC6pSVZ8HxZBs4vjKxIUinluoA=";
                };
                nativeBuildInputs = with pkgs; [ zsh ];
                dontBuild = true;
                installPhase = ''
                  runHook preInstall
                  zsh build.zsh
                  mkdir -p $out/bin
                  cp zunit $out/bin/
                  mkdir -p $out/share/zsh/site-functions
                  cp zunit.zsh-completion $out/share/zsh/site-functions/_zunit
                  runHook postInstall
                '';
              };
            };
            devShells.default = pkgs.mkShellNoCC {
              buildInputs = [
                pkgs.zsh
                packages.revolver
                packages.zunit
              ];
              shellHook = ''
                if [[ -z "''${DIRENV_IN_ENVRC:-}" ]]; then
                  exec zsh
                fi
              '';
            };
          }
      );
}
