{ mkDerivation, base, hakyll, latex-svg-image, latex-svg-pandoc, lrucache
, pandoc-types, stdenv }:
mkDerivation {
  pname = "latex-svg-hakyll";
  version = "0.2";
  sha256 = "3c07ca35136d840884f1f2876fa197105e5ec9f1b62ad56a00b864939ab6372f";
  libraryHaskellDepends =
    [ base hakyll latex-svg-image latex-svg-pandoc lrucache pandoc-types ];
  homepage = "https://github.com/phadej/latex-svg#readme";
  description = "Use actual LaTeX to render formulae inside Hakyll pages";
  license = stdenv.lib.licenses.bsd3;
}
