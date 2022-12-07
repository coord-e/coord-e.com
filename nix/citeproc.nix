{ mkDerivation, aeson, attoparsec, base, bytestring, case-insensitive
, containers, data-default, Diff, directory, file-embed, filepath, lib, mtl
, pandoc-types, pretty, rfc5051, safe, scientific, text, timeit, transformers
, uniplate, vector, xml-conduit }:
mkDerivation {
  pname = "citeproc";
  version = "0.1.0.3";
  sha256 = "b7ff1c326aa2033801514def980c5cbf6e816e5ff5366e1d0d358b05809df383";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson
    attoparsec
    base
    bytestring
    case-insensitive
    containers
    data-default
    file-embed
    filepath
    pandoc-types
    rfc5051
    safe
    scientific
    text
    transformers
    uniplate
    vector
    xml-conduit
  ];
  testHaskellDepends = [
    aeson
    base
    bytestring
    containers
    Diff
    directory
    filepath
    mtl
    pretty
    text
    timeit
    transformers
  ];
  description = "Generates citations and bibliography from CSL styles";
  license = lib.licenses.bsd2;
}
