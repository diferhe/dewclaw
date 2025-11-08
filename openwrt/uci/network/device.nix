{ lib, ... }:

let
  device =
    with lib;
    mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "eth0";
              description = ''
                L3 device name.

                Needs to match the `device` option of the respective interface section.
              '';
            };

            macaddr = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "62:11:22:aa:bb:cc";
              description = ''
                MAC address overriding the default one for this device.
              '';
            };

            type = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "bridge";
              description = ''
                Device type. Can be VLAN type: possible values: 8021q or 8021ad.
                If set to `bridge`, creates a bridge of the given name using L2 devices listed in `ports`
                and wireless interfaces assigned using the `network` option in the wireless configuration.
              '';
            };

            ifname = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "eth0";
              description = ''
                The base L2 device required when using the `macvlan` device type.  
                Install the `kmod-macvlan` package if necessary.
              '';
            };

            ports = mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              example = [
                "eth0"
                "eth1"
              ];
              description = ''
                List of L2 device names that form part of this bridge.
              '';
            };

            rxpause = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1";
              description = ''
                Controls the receive (RX) flow control.  
                Setting it to `1` enables RX pause frames, allowing the interface to signal senders to pause
                when overwhelmed by incoming data.
              '';
            };

            txpause = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1";
              description = ''
                Controls the transmission (TX) flow control.  
                Setting it to `1` enables TX pause frames, allowing the interface to temporarily stop sending
                data when the receiver is overloaded.
              '';
            };

            autoneg = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1";
              description = ''
                Enables auto-negotiation (`1`) to automatically determine link parameters
                such as speed and duplex mode with the connected device.
              '';
            };

            speed = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1000";
              description = ''
                Configures the link speed (e.g., 10, 100, 1000 for Mbps).
              '';
            };

            duplex = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1";
              description = ''
                Configures duplex mode:  
                `1` = Full Duplex, `0` = Half Duplex.
              '';
            };

            table = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "100";
              description = ''
                When type is set to `vrf`, sets the routing table name or number.
              '';
            };

            vid = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 10;
              description = ''
                VLAN ID for this device.   
                Specifies the Virtual Local Area Network (VLAN) identifier.
              '';
            };
          };
        }
      );
      description = "Network device definitions for UCI network configuration.";
    };

in
{
  options.uci.settings.network.device = device;
}
