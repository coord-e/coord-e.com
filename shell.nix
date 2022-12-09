{ pkgs ? import ./nix/pkgs.nix { } }:
with pkgs;

mkShell {
  buildInputs = [
    # for generator
    git
    graphviz
    (callPackage ./nix/texlive-combined.nix { })
    (callPackage ./generator { })
    librsvg
    # for textlint/prettier
    nodejs
    # formatting
    nixfmt
    hlint
    ormolu
  ];
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ noto-fonts-cjk ]; };
  LANG = "C.UTF-8";
}
