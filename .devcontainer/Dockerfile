FROM ghcr.io/nixos/nix:latest

RUN nix-env -iA cachix -f https://cachix.org/api/v1/install
RUN cachix use coord-e-com
