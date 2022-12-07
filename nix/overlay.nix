self: super: {
  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      latex-svg-hakyll = super.haskell.lib.appendPatch
        (hsuper.callPackage ./latex-svg-hakyll.nix { })
        ./latex-svg-hakyll.patch;
      latex-svg-pandoc = super.haskell.lib.appendPatch
        (hsuper.callPackage ./latex-svg-pandoc.nix { })
        ./latex-svg-pandoc.patch;
      hakyll = hsuper.callPackage ./hakyll.nix { };
      citeproc = hsuper.callPackage ./citeproc.nix { };
      pandoc-types = hsuper.callPackage ./pandoc-types.nix { };
      commonmark-pandoc = hsuper.callPackage ./commonmark-pandoc.nix { };
      texmath = hsuper.callPackage ./texmath.nix { };
      skylighting = hsuper.callPackage ./skylighting.nix { };
      skylighting-core = hsuper.callPackage ./skylighting-core.nix { };
      pandoc =
        super.haskell.lib.appendPatch (hsuper.callPackage ./pandoc.nix { })
        ./pandoc.patch;
    };
  };
}
