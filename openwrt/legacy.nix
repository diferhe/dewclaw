{
  config,
  lib,
  pkgs,
  ...
}:

let
  devType = lib.types.submoduleWith {
    specialArgs.pkgs = pkgs;
    description = "OpenWrt configuration";
    modules = [ ./default.nix ];
  };

in

{
  options = {
    warnings = lib.mkOption {
      internal = true;
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };

    assertions = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      internal = true;
      default = [ ];
      example = [
        {
          assertion = false;
          message = "you can't enable this for that reason";
        }
      ];
      description = ''
        This option allows modules to express conditions that must
        hold for the evaluation of the system configuration to
        succeed, along with associated error messages for the user.
      '';
    };

    openwrt = lib.mkOption {
      type = lib.types.attrsOf devType;
      default = { };
      description = ''
        OpenWrt device configurations. Each attribute will produce an independent deployment
        script that applies the corresponding configuration to the target device.
      '';
    };
  };

  config = {
    warnings = lib.flatten (
      lib.mapAttrsToList (
        name: dev: lib.map (msg: "in configuration for device ${name}: " + msg) dev.warnings
      ) config.openwrt
    );

    assertions = lib.flatten (
      lib.mapAttrsToList (
        name: dev:
        lib.map (assertion: {
          inherit (assertion) assertion;
          message = "in configuration for device ${name}: " + assertion.message;
        }) dev.assertions
      ) config.openwrt
    );
  };
}
