{
  pkgs ? import <nixpkgs> { },
}:

import ../../. {
  inherit pkgs;
  configuration = ./example-legacy.nix;
}
