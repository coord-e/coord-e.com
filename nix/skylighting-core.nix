{ mkDerivation, aeson, ansi-terminal, attoparsec, base, base64-bytestring
, binary, blaze-html, bytestring, case-insensitive, colour, containers
, criterion, Diff, directory, filepath, HUnit, hxt, lib, mtl, pretty-show
, QuickCheck, random, safe, tasty, tasty-golden, tasty-hunit, tasty-quickcheck
, text, transformers, utf8-string }:
mkDerivation {
  pname = "skylighting-core";
  version = "0.10.1";
  sha256 = "7dbb596ae091f6ba76875435bed8abf8e25abf196f98dcfc1c2bc86f7a18aa81";
  revision = "1";
  editedCabalFile = "1qmv3mq963lpbp8kil28dh0c2xf7apsgcpzydcrqyczmvqmndaac";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson
    ansi-terminal
    attoparsec
    base
    base64-bytestring
    binary
    blaze-html
    bytestring
    case-insensitive
    colour
    containers
    directory
    filepath
    hxt
    mtl
    safe
    text
    transformers
    utf8-string
  ];
  testHaskellDepends = [
    aeson
    base
    bytestring
    containers
    Diff
    directory
    filepath
    HUnit
    pretty-show
    QuickCheck
    random
    tasty
    tasty-golden
    tasty-hunit
    tasty-quickcheck
    text
    utf8-string
  ];
  benchmarkHaskellDepends =
    [ base containers criterion directory filepath text ];
  homepage = "https://github.com/jgm/skylighting";
  description = "syntax highlighting library";
  license = lib.licenses.bsd3;
}
