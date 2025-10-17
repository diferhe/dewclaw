{ lib }:
rec {
  openwrtConfiguration =
    {
      name ? "unnamed",
      check ? true,
      extraSpecialArgs ? { },
      lib ? pkgs.lib,
      modules ? [ ],
      pkgs,
    }:
    let

      evaluated = lib.evalModules {
        class = "openwrt";
        modules = [
          ./openwrt/default.nix
        ] ++ modules;
        specialArgs = {
          inherit pkgs name;
        } // extraSpecialArgs;
      };
    in
    lib.asserts.checkAssertWarn evaluated.config.assertions evaluated.config.warnings (
      evaluated // { deployScript = evaluated.config.build.deploy; }
    );

  mkOpenwrtConfigurations =
    pkgs: configurations:
    lib.mapAttrs (name: conf: openwrtConfiguration ({ inherit name pkgs; } // conf)) configurations;

  mkDewclawEnv =
    pkgs: configurations:
    let
      targets = lib.mapAttrs (_: conf: conf.deployScript) configurations;
    in
    pkgs.buildEnv {
      name = "dewclaw-env";

      paths = lib.attrValues targets;

      passthru = { inherit targets; };
    };
}
