{ lib, ... }:
with lib;
let
  interface = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          device = mkOption {
            type = types.str;
            example = "eth0.1";
            description = ''
              L3 device name, such as eth0.1, eth2, tun0, br-lan, etc.
              Needs to match the name option of the respective device section.
              Do not specify wireless interfaces directly; instead, assign them to bridges.
              May be empty or missing for protocols like pptp, pppoa, 6in4, etc.
            '';
          };

          mtu = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Override the default MTU on this interface.";
          };

          auto = mkOption {
            type = types.nullOr types.bool;
            default = null; # Will set default dynamically depending on proto
            description = "Specifies whether to bring up the interface on boot.";
          };

          ipv6 = mkOption {
            type = types.nullOr types.bool;
            default = true;
            description = "Enable (1) or disable (0) IPv6 on this interface.";
          };

          force_link = mkOption {
            type = types.nullOr types.bool;
            default = null; # Will set default based on proto
            description = ''
              Specifies whether IP address, route, and optionally gateway
              are assigned to the interface regardless of the link being active ('1')
              or only after the link has become active ('0').
            '';
          };

          disabled = mkOption {
            type = types.nullOr types.bool;
            default = false;
            description = "Enable or disable this interface section.";
          };

          ip4table = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "IPv4 routing table for routes of this interface.";
          };

          ip6table = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "IPv6 routing table for routes of this interface.";
          };
          proto =
            let
              optionDocs = {
                "static" = "Static configuration with fixed address and netmask. Program: ip/ifconfig";
                "dhcp" = "Address and netmask are assigned by DHCP. Program: udhcpc (Busybox)";
                "dhcpv6" = "Address and netmask are assigned by DHCPv6. Program: odhcpc6c";
                "ppp" = "PPP protocol - dialup modem connections. Program: pppd";
                "pppoe" = "PPP over Ethernet - DSL broadband connection. Program: pppd + plugin rp-pppoe.so";
                "pppoa" = "PPP over ATM - DSL connection using a builtin modem. Program: pppd + plugin ...";
                "3g" = "CDMA, UMTS or GPRS connection using an AT-style 3G modem. Program: comgt";
                "qmi" = "USB modems using QMI protocol. Program: uqmi";
                "ncm" = "USB modems using NCM protocol. Program: comgt-ncm + ?";
                "wwan" = "USB modems with protocol autodetection. Program: wwan";
                "hnet" = "Self-managing home network (HNCP). Program: hnet-full";
                "pptp" = "Connection via PPtP VPN. Program: ?";
                "6in4" = "IPv6-in-IPv4 tunnel for use with Tunnel Brokers like HE.net. Program: ?";
                "aiccu" = "Anything-in-anything tunnel. Program: aiccu";
                "6to4" = "Stateless IPv6 over IPv4 transport. Program: ?";
                "6rd" = "IPv6 rapid deployment. Program: 6rd";
                "dslite" = "Dual-Stack Lite. Program: ds-lite";
                "l2tp" = "PPP over L2TP Pseudowire Tunnel. Program: xl2tpd";
                "relay" = "relayd pseudo-bridge. Program: relayd";
                "gre" = "GRE over IPv4. Program: gre + kmod-gre";
                "gretap" = "GRE over IPv4. Program: gre + kmod-gre";
                "grev6" = "GRE over IPv6. Program: gre + kmod-gre6";
                "grev6tap" = "GRE over IPv6. Program: gre + kmod-gre6";
                "vti" = "VTI over IPv4. Program: vti + kmod-ip_vti";
                "vtiv6" = "VTI over IPv6. Program: vti + kmod-ip6_vti";
                "vxlan" =
                  "VXLAN protocol for layer 2 virtualization, see here for further information and a configuration example. Program: vxlan + kmod-vxlan + ip-full";
                "none" =
                  "Unspecified protocol, therefore all the other interface settings will be ignored (like disabling the configuration). Program: -";

              };
            in
            mkOption {
              type = types.enum (attrNames optionDocs);
              default = null;
              description = ''
                Protocol used by this interface.
                ${concatMapStringsSep "\n\n" (name: "- ``${name}``: ${optionDocs.${name}}") (attrNames optionDocs)}
              '';
            };
          ipaddr = mkOption {
            type = types.nullOr (
              types.oneOf [
                types.str
                (types.listOf types.str)
              ]
            );
            default = null;
            example = [
              "192.168.1.1"
              "192.168.1.2"
            ];
            description = ''
              IPv4 address or list of addresses assigned to this interface or IP address to request from the DHCP server.
              If both ipaddr and ip6addr are unset, this must be defined for static setups.
            '';
          };

          netmask = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "255.255.255.0";
            description = "Netmask for the IPv4 address.";
          };

          gateway = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "192.168.1.254";
            description = "Default gateway address.";
          };

          broadcast = mkOption {
            type = types.nullOr (types.either types.str types.bool);
            default = null;
            example = "192.168.1.255";
            description = ''
              Broadcast address (autogenerated if not set)
              or enable the broadcast flag in DHCP requests (required for certain ISPs, e.g. Charter with DOCSIS
            '';
          };

          dns_metric = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 0;
            description = "DNS metric for this interface.";
          };

          dns_search = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            example = [
              "example.com"
              "lan"
            ];
            description = ''
              Search list for hostname lookup (only relevant for routers).
            '';
          };

          metric = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 0;
            description = "Default route metric for this interface.";
          };

          hostname = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "router";
            description = "Hostname to include in DHCP requests (option 12).";
          };

          clientid = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "01:23:45:67:89:ab";
            description = ''
              Override client identifier in DHCP requests (option 61).
              Override DHCPv6 client identifier (Option 1).
              Default is DUID-LL (type 3) = 00030001 + device MAC address (RFC 8415).
            '';
          };

          vendorid = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "udhcp 1.33.1";
            description = "Override vendor class in DHCP requests (option 60).";
          };

          dns = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            example = [
              "8.8.8.8"
              "8.8.4.4"
            ];
            description = ''
              Supplement DHCP-assigned DNS servers, or use only these if peerdns = false.
            '';
          };

          peerdns = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "Use DNS servers provided by DHCP.";
          };

          defaultroute = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "Whether to create a default route via the received gateway.";
          };

          customroutes = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "10.10.0.0/16 10.11.0.0/16";
            description = "Space-separated list of additional routes to insert via the received gateway.";
          };

          classlessroute = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = ''
              Whether to request the “classless route” option (DHCP option 121).
            '';
          };

          reqopts = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "42 121";
            description = "Space-separated list of additional DHCP options to request from the server.";
          };

          sendopts = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "hostname:myrouter vendorid:custom";
            description = ''
              Space-separated list of additional DHCP options to send to the server.
              Syntax: option:value, where option is either a numeric code or a symbolic name (e.g. hostname).
            '';
          };

          norelease = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "If set, do not release the DHCP address on interface shutdown.";
          };

          zone = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "wan";
            description = "Firewall zone to which this interface should be added.";
          };

          reqaddress = mkOption {
            type = types.nullOr (
              types.enum [
                "try"
                "force"
                "none"
              ]
            );
            default = null;
            example = "try";
            description = "Behavior for requesting addresses.";
          };

          reqprefix = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "auto";
            description = ''
              Specifies the behavior for requesting IPv6 prefixes.
              Numbers denote hinted prefix length (e.g., 0–64).
              If set to "no", only a single IPv6 address is requested for the AP itself.
              A specific prefix can be requested as <prefix>/<length> (e.g., 2001:db8::/56).
            '';
          };

          keep_ra_dnslifetime = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Ignore default lifetime for RDNSS records.";
          };

          defaultreqopts = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "If set to false, request only the options specified in reqopts.";
          };

          noslaaconly = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Don't allow configuration via SLAAC only (implied by reqprefix != no).";
          };

          forceprefix = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Require presence of an IPv6 prefix in the received DHCP message.";
          };

          ip6prefix = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "2001:db8:1::/48";
            description = "User-provided IPv6 prefix for distribution to clients.";
          };

          extendprefix = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = ''
              On 3GPP mobile WAN links, accept a /64 prefix via SLAAC and extend it on one downstream interface (RFC 7278).
            '';
          };

          iface_dslite = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "dslite0";
            description = ''
              Logical interface template for DS-Lite autoconfiguration.
              0 disables DS-Lite autoconfiguration.
            '';
          };

          zone_dslite = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "wan";
            description = "Firewall zone of the DS-Lite interface.";
          };

          iface_map = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "map0";
            description = ''
              Logical interface template for MAP-E/MAP-T/lw6o4 autoconfiguration.
              0 disables map autoconfiguration.
            '';
          };

          zone_map = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "wan";
            description = "Firewall zone of the MAP interface.";
          };

          iface_464xlat = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "clat0";
            description = ''
              Logical interface template for 464xlat autoconfiguration.
              0 disables 464xlat autoconfiguration.
            '';
          };

          zone_464xlat = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "wan";
            description = "Firewall zone of the 464xlat interface.";
          };

          sourcefilter = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "Enable source-based IPv6 routing.";
          };

          vendorclass = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "MyISPClass";
            description = "Vendor class to be included in DHCPv6 messages (Option 16).";
          };

          userclass = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "Residential";
            description = "User class to be included in DHCPv6 messages (Option 15).";
          };

          delegate = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "Enable prefix delegation for DS-Lite/MAP/464xlat.";
          };

          soltimeout = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 120;
            description = "Maximum solicit timeout (seconds).";
          };

          fakeroute = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = "Fake a default route when no RA route info is received.";
          };

          ra_holdoff = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 3;
            description = "Minimum time in seconds between accepting RA updates.";
          };

          noclientfqdn = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = ''
              Don't send Client FQDN option (Option 39).
              Default uses the system hostname (e.g., OpenWrt).
            '';
          };

          noacceptreconfig = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Don't send Accept Reconfigure option.";
          };

          noserverunicast = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Ignore Server Unicast option.";
          };

          skpriority = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 0;
            description = "Set packet kernel priority.";
          };

          verbose = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Increase logging verbosity.";
          };

          ip6addr = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "2001:db8:1::1/64";
            description = "Assign given IPv6 address to this interface (CIDR notation). Required if no ipaddr is set.";
          };

          ip6ifaceid = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "::1";
            description = ''
              IPv6 interface identifier or suffix. Allowed values: "eui64", "random", or a fixed value like "::1:2".
              Do not use "::" (reserved anycast address).
              When an IPv6 prefix is delegated, this suffix is appended to form the interface address.
              When using dhcp the interface identifier for addresses received via RA (Router Advertisement).
            '';
          };

          ip6gw = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "2001:db8::1";
            description = "Assign given IPv6 default gateway to this interface.";
          };

          ip6assign = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 64;
            description = "Delegate a prefix of given length to this interface.";
          };

          ip6hint = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "0a";
            description = "Hint the subprefix-ID that should be delegated as a hexadecimal number.";
          };

          ip6class = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            example = [
              "wan"
              "isp"
            ];
            description = "Define the IPv6 prefix-classes this interface will accept.";
          };

          ip6deprecated = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = false;
            description = "Set preferred lifetime of IPv6 addresses to zero (mark addresses as deprecated).";
          };

          layer = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 3;
            description = ''
              Selects the interface layer to attach to for stacked protocols (e.g., tun over bridge over eth, ppp over eth, etc.).

              • 3 → attach to a layer 3 interface (tun*, ppp*).  
                If the parent is not layer 3, fallback to layer 2.  
              • 2 → attach to a layer 2 interface (br-*).  
                If the parent is not a bridge, fallback to layer 1.  
              • 1 → attach to a layer 1 interface (eth*, wlan*).  

              Default is 3.
            '';
          };

        };
      }
    );
    description = "Network interface";
  };
in
{
  options.uci.settings.network.interface = interface;
}
