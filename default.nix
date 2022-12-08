{ pkgs ? import ./nix/pkgs.nix { } }:
with pkgs;

let generator = callPackage ./generator { };
in stdenv.mkDerivation {
  name = "coord-e-com";
  src = ./content;
  nativeBuildInputs =
    [ graphviz (callPackage ./nix/texlive-combined.nix { }) generator librsvg ];
  LANG = "C.UTF-8";
  GENERATOR_COMMIT_ID = lib.commitIdFromGitRepo ./.git;
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ noto-fonts-cjk ]; };
  buildPhase = "${generator}/bin/generate-coord-e-com build";
  installPhase = "cp -a _site $out";
}
