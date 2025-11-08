{ lib, ... }:
let
  globals =
    with lib;
    mkOption {
      type = types.submodule {
        options = {
          ula_prefix = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "auto";
            description = ''
              IPv6 ULA prefix for this device.  
              May be set to an explicit IPv6 prefix (e.g. `fd00:abcd::/48`) or to `auto` to automatically generate one.
            '';
          };

          packet_steering = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 2;
            description = ''
              Enables packet steering to distribute network traffic handling across multiple CPUs.

              • `0` — disabled  
              • `1` — enabled  
              • `2` — enabled for all CPUs
            '';
          };

          tcp_l3mdev = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = ''
              Toggles the `net.ipv4.tcp_l3mdev_accept` flag (for VRF).  
              When enabled, TCP sockets can receive traffic on all VRF devices.
            '';
          };

          udp_l3mdev = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = ''
              Toggles the `net.ipv4.udp_l3mdev_accept` flag (for VRF).  
              When enabled, UDP sockets can receive traffic on all VRF devices.
            '';
          };
        };
      };

      default = { };
      description = "Global network settings for UCI network configuration.";
    };
in
{
  options.uci.settings.network.globals = globals;
}
