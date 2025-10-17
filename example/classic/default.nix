{
  pkgs ? import <nixpkgs> { },
}:

import ../../. {
  example = {
    inherit pkgs;
    modules = [ ./example.nix ];
  };
}
