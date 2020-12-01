self: super: {
  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      latex-svg-hakyll = super.haskell.lib.appendPatch
        (hsuper.callPackage ./latex-svg-hakyll.nix { })
        ./latex-svg-hakyll.patch;
      latex-svg-pandoc = super.haskell.lib.appendPatch
        (hsuper.callPackage ./latex-svg-pandoc.nix { })
        ./latex-svg-pandoc.patch;
      pandoc = super.haskell.lib.appendPatch hsuper.pandoc ./pandoc.patch;
    };
  };
}
