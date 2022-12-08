{ mkDerivation, base, commonmark, commonmark-extensions, containers, lib
, pandoc-types, text }:
mkDerivation {
  pname = "commonmark-pandoc";
  version = "0.2.0.1";
  sha256 = "03624bad9808639c93d4ba6a8d0a6f528dfedbbe7da5dcb3daa3294c8c06428b";
  libraryHaskellDepends =
    [ base commonmark commonmark-extensions containers pandoc-types text ];
  homepage = "https://github.com/jgm/commonmark-hs";
  description = "Bridge between commonmark and pandoc AST";
  license = lib.licenses.bsd3;
}
