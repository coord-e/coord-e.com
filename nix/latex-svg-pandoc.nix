{ mkDerivation, base, bytestring, directory, filepath, latex-svg-image
, pandoc-types, stdenv, text }:
mkDerivation {
  pname = "latex-svg-pandoc";
  version = "0.2.1";
  sha256 = "a2404cdebb27b86be4ce1db86d2bb874393d31e33266d222e11a72d2e5553c8b";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends =
    [ base bytestring directory filepath latex-svg-image pandoc-types text ];
  executableHaskellDepends = [ base latex-svg-image pandoc-types ];
  homepage = "http://github.com/phadej/latex-svg#readme";
  description =
    "Render LaTeX formulae in pandoc documents to images with an actual LaTeX";
  license = stdenv.lib.licenses.bsd3;
}
