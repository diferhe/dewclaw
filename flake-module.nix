{
  lib,
  flake-parts-lib,
  moduleLocation,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    literalExpression
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    mkSubmoduleOptions
    ;
in
mkTransposedPerSystemModule {
  name = "openwrtConfigurations";
  option = mkOption {
    type = types.lazyAttrsOf types.raw;
    default = { };
    description = "OpenWrt (dewclaw) configurations to build.";
    example = literalExpression ''
      {
        example = inputs.dewclaw.lib.openwrtConfiguration {
          inherit pkgs
          modules = [
            ./example/classic/example.nix
          ];
        };
      }
    '';
  };
  file = moduleLocation;
}
# // {
#   options = {
#     flake = mkSubmoduleOptions {
#       openwrtModules = mkOption {
#         type = types.lazyAttrsOf types.deferredModule;
#         default = { };
#         apply = mapAttrs (
#           name: mod: {
#             _class = "openwrt";
#             _file = "${toString moduleLocation}#openwrtModules.${name}";
#             imports = [ mod ];
#           }
#         );
#         description = "OpenWrt (dewclaw) modules.";
#       };
#     };
#   };
# }
