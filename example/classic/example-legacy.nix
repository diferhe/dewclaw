# example config for a qemu image of openwrt that is accessible
# via port 2222 on localhost. the root password is set to `a`
# and a few utilities are installed, otherwise the configuration
# is a subset of the default config.
#
# to use this example run a squashfs image of openwrt
# (eg https://downloads.openwrt.org/releases/22.03.5/targets/x86/64/openwrt-22.03.5-x86-64-generic-squashfs-combined.img.gz)
# with something like
#
#   qemu-system-x86_64 -M q35,accel=kvm \
#     -drive file=openwrt-22.03.5-x86-64-generic-squashfs-combined.img,id=d0,if=none,bus=0,unit=0 \
#     -device ide-hd,drive=d0,bus=ide.0 \
#     -nic user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80
#
# and run `uci set network.lan.proto=dhcp; uci commit; reload_config`
# from the serial console.
#
# age keys for sops are as follow:
#
# SOPS_AGE_KEY=AGE-SECRET-KEY-1292U9T04N6MJUK223038MD246X4G2K8GPDWHVHY09JVCLSRUS6TQ6988D9

{
  openwrt.example = import ./example.nix;
}
