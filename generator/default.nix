{ pkgs ? import ../nix/pkgs.nix { } }:
with pkgs;

haskellPackages.callCabal2nix "generate-coord-e-com" ./. { }
