{ nixpkgs ? import ./nixpkgs.nix }:

nixpkgs { overlays = [ (import ./overlay.nix) ]; }
