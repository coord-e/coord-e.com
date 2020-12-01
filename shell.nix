{ pkgs ? import ./nix/pkgs.nix { } }:
with pkgs;

mkShell {
  buildInputs = [
    # for generator
    git
    graphviz
    (callPackage ./nix/texlive-combined.nix { })
    (callPackage ./generator { })
    # for textlint/prettier
    nodejs
    # formatting
    nixfmt
    hlint
    ormolu
  ];
  shellHook = ''
    export LANG=C.UTF-8
  '';
}
