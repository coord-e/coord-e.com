{ nixpkgs ? import ./nix/nixpkgs.nix }:

let
  overlay = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper: {
        latex-svg-hakyll = pkgs.haskell.lib.appendPatch
          (hsuper.callPackage ./nix/latex-svg-hakyll.nix { })
          ./nix/latex-svg-hakyll.patch;
        latex-svg-pandoc = pkgs.haskell.lib.appendPatch
          (hsuper.callPackage ./nix/latex-svg-pandoc.nix { })
          ./nix/latex-svg-pandoc.patch;
        pandoc = pkgs.haskell.lib.appendPatch hsuper.pandoc ./nix/pandoc.patch;
      };
    };
  };

  pkgs = import nixpkgs { overlays = [ overlay ]; };

  generate-coord-e-com =
    pkgs.haskellPackages.callCabal2nix "generate-coord-e-com" ./generator { };

  texlive-combined = with pkgs;
    texlive.combine { inherit (texlive) scheme-basic preview dvisvgm; };

  coord-e-com = pkgs.stdenv.mkDerivation {
    name = "coord-e-com";
    src = ./content;
    nativeBuildInputs = with pkgs; [ texlive-combined generate-coord-e-com ];
    buildPhase = ''
      export LANG=C.UTF-8
      export GENERATOR_COMMIT_ID=${pkgs.lib.commitIdFromGitRepo ./.git}
      ${generate-coord-e-com}/bin/generator build
    '';
    installPhase = "cp -a _site $out";
  };

in {
  inherit coord-e-com generate-coord-e-com;
  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      git
      texlive-combined
      generate-coord-e-com
      nixfmt
      hlint
      ormolu
    ];
  };
}
