{
  pkgs ? import <nixpkgs> { },
}:
let
  dewclawLib = import ./lib.nix { inherit (pkgs) lib; };
  openwrtConfigurations = dewclawLib.mkOpenwrtConfigurations {
    inherit pkgs;
    configurations = {
      example = {
        modules = [
          ./example.nix
        ];
      };
    };
  };
in
with dewclawLib;
mkDewclawEnv {
  inherit pkgs;
  inherit openwrtConfigurations;
}
