{ nixpkgs ? import ./nix/nixpkgs.nix }:

let
  overlay = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper: {
        generate-coord-e-com =
          hself.callCabal2nix "generate-coord-e-com" ./generator { };
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
in {
  generate-coord-e-com = pkgs.haskellPackages.generate-coord-e-com;
  shell = pkgs.haskellPackages.shellFor {
    packages = hp: with hp; [ generate-coord-e-com ];
    buildInputs = with pkgs; [
      (texlive.combine {
        inherit (texlive) scheme-basic preview extsizes dvisvgm;
      })
      nixfmt
      cabal-install
      nodePackages.prettier
      haskellPackages.hlint
      haskellPackages.ormolu
    ];
  };
}
