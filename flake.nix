{
  description = "dewclaw: semi-declarative OpenWrt configuration ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.flake-parts.flakeModules.flakeModules
        ./flake-module.nix
      ];

      systems = [ "x86_64-linux" ];
      debug = true;
      flake.modules.flake.openwrt = ./openwrt;
      flake.flakeModules = rec {
        openwrt = ./flake-module.nix;
        default = openwrt;
      };
      flake.lib = import ./lib.nix {
        inherit (nixpkgs) lib;
      };
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        rec {
          formatter = pkgs.nixfmt-rfc-style;
          packages = {
            dewclaw-env = pkgs.callPackage ./default.nix { inherit openwrtConfigurations; };
            dewclaw-book = pkgs.callPackage ./doc { };
            default = self.packages.x86_64-linux.dewclaw-env;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt-rfc-style
              pkgs.shfmt
              pkgs.treefmt
              pkgs.nixd
            ];
          };
          openwrtConfigurations = self.lib.mkOpenwrtConfigurations pkgs {
            example = {
              modules = [
                ./example/test.nix
              ];
            };
            example2 = {
              modules = [
                ./example/test.nix
              ];
            };
          };
        };
    };
}
