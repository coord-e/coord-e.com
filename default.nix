{ pkgs ? import ./nix/pkgs.nix { } }:
with pkgs;

let generator = callPackage ./generator { };
in stdenv.mkDerivation {
  name = "coord-e-com";
  src = ./content;
  nativeBuildInputs =
    [ (callPackage ./nix/texlive-combined.nix { }) generator ];
  buildPhase = ''
    export LANG=C.UTF-8
    export GENERATOR_COMMIT_ID=${lib.commitIdFromGitRepo ./.git}
    ${generator}/bin/generate-coord-e-com build
  '';
  installPhase = "cp -a _site $out";
}
