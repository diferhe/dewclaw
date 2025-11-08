{ lib, ... }:
let
  bridge-vlan =
    with lib;
    mkOption {
      type = types.submodule {
        options = {
          device = mkOption {
            type = types.str;
            example = "br-lan";
            description = "The bridge device to which the VLANs will be applied.";
          };
          vlan = mkOption {
            type = types.int;
            example = 1;
            description = "The VLAN ID to assign to the bridge.";
          };
          ports = mkOption {
            type = types.listOf types.str;
            example = [
              "lan1:t"
              "lan2:u*"
            ];
            description = ''
              List of ports to add to the bridge VLAN.  
              Each port may be suffixed with `:t` to mark it as tagged, or `:u` to mark it as untagged.  
              An asterisk (`*`) may be appended to indicate that the port is the PVID (default VLAN) for untagged traffic.
            '';
          };
        };
      };
    };
in
{
  options.uci.network.bridge-vlan = bridge-vlan;
}
