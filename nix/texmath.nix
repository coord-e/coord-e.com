{ mkDerivation, base, bytestring, containers, directory, filepath, lib, mtl
, pandoc-types, parsec, process, syb, temporary, text, utf8-string, xml }:
mkDerivation {
  pname = "texmath";
  version = "0.12.0.3";
  sha256 = "318771c696dfa4fc57edf984f3aa35f0cb1792119cf2e27601b6267d9e1d4918";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends =
    [ base containers mtl pandoc-types parsec syb text xml ];
  testHaskellDepends = [
    base
    bytestring
    directory
    filepath
    process
    temporary
    text
    utf8-string
    xml
  ];
  homepage = "http://github.com/jgm/texmath";
  description = "Conversion between formats used to represent mathematics";
  license = lib.licenses.gpl2Only;
}
