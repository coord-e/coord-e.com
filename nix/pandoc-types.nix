{ mkDerivation, aeson, base, bytestring, containers, criterion, deepseq
, ghc-prim, HUnit, lib, QuickCheck, string-qq, syb, test-framework
, test-framework-hunit, test-framework-quickcheck2, text, transformers }:
mkDerivation {
  pname = "pandoc-types";
  version = "1.22.2.1";
  sha256 = "4ce796129d67c73967bc0b301c7110bc7dbab7a53b4d1e147ba257991661659d";
  libraryHaskellDepends = [
    aeson
    base
    bytestring
    containers
    deepseq
    ghc-prim
    QuickCheck
    syb
    text
    transformers
  ];
  testHaskellDepends = [
    aeson
    base
    bytestring
    containers
    HUnit
    QuickCheck
    string-qq
    syb
    test-framework
    test-framework-hunit
    test-framework-quickcheck2
    text
  ];
  benchmarkHaskellDepends = [ base criterion text ];
  homepage = "https://pandoc.org/";
  description = "Types for representing a structured document";
  license = lib.licenses.bsd3;
}
