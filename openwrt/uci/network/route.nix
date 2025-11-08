{ lib, ... }:
let
  route =
    with lib;
    mkOption {
      type = types.submodule {
        options = {
          interface = mkOption {
            type = types.str;
            example = "wan";
            description = "The network interface for the route.";
          };
          target = mkOption {
            type = types.str;
            example = "172.16.2.0";
            description = "The target network for the route.";
          };
          netmask = mkOption {
            type = types.str;
            example = "255.255.255.0";
            description = "The netmask for the target network.";
          };
          gateway = mkOption {
            type = types.str;
            example = "10.2.2.1";
            description = "The gateway IP address for the route.";
          };
        };
      };
    };

  rule =
    with lib;
    mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            "in" = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "lan";
              description = ''
                Specifies the incoming logical interface name.
              '';
            };

            out = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "wan";
              description = ''
                Specifies the outgoing logical interface name.
              '';
            };

            src = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "192.168.1.0/24";
              description = ''
                Specifies the source subnet to match (CIDR notation).
              '';
            };

            dest = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "10.0.0.0/8";
              description = ''
                Specifies the destination subnet to match (CIDR notation).
              '';
            };

            tos = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 16;
              description = ''
                Specifies the TOS (Type of Service) value to match in IP headers.
              '';
            };

            mark = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "0x0/0x1";
              description = ''
                Specifies the fwmark and optionally its mask to match, e.g. `0xFF` to match mark 255  
                or `0x0/0x1` to match any even mark value.
              '';
            };

            uidrange = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "1000-1005";
              description = ''
                Specifies an individual UID or range of UIDs to match,  
                e.g. `1000` to match a single UID or `1000-1005` for a range.
              '';
            };

            suppress_prefixlength = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 8;
              description = ''
                Reject routing decisions that have a prefix length less than or equal to the specified value.
              '';
            };

            ipproto = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 6;
              description = ''
                Specifies the protocol number in IP rule configuration (0–255),  
                aligning with IANA protocol numbers.
              '';
            };

            invert = mkOption {
              type = types.nullOr types.bool;
              default = null;
              example = true;
              description = ''
                If set to `true`, the meaning of the match options is inverted.
              '';
            };

            priority = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 1000;
              description = ''
                Controls the order of IP rules.  
                By default, the priority is auto-assigned based on declaration order.
              '';
            };

            lookup = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "main";
              description = ''
                Specifies a routing table lookup target.  
                May be a numeric ID (0–65535) or a symbolic alias (e.g. `local`, `main`, `default`).
              '';
            };

            goto = mkOption {
              type = types.nullOr types.int;
              default = null;
              example = 200;
              description = ''
                Specifies a jump to another rule by its priority value.
              '';
            };

            action =
              let
                optionDocs = {
                  unicast = "Permit the traffic; the rule returns the route found in the routing table referenced by the rule";
                  prohibit = "When reaching the rule, respond with ICMP prohibited messages and abort route lookup";
                  unreachable = "When reaching the rule, respond with ICMP unreachable messages and abort route lookup";
                  blackhole = "When reaching the rule, drop packet and abort route lookup";
                  throw = "Stop lookup in the current routing table even if a default route exists";
                };
              in
              mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "unreachable";
                description = ''
                  Specifies one of the supported routing actions:
                  ${concatMapStringsSep "\n\n" (name: "- ``${name}``: ${optionDocs.${name}}") (attrNames optionDocs)}
                '';
              };

            disabled = mkOption {
              type = types.nullOr types.bool;
              default = null;
              example = true;
              description = ''
                If set to `true`, the rule will not be applied.
              '';
            };
          };
        }
      );
      description = "Netifd supports IP rule declarations which are required to implement policy routing.";
    };
in
{
  options.uci.settings.network.route = route;
  options.uci.settings.network.rule = rule;
  options.uci.settings.network.rule6 = rule;
}
