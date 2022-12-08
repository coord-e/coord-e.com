{ mkDerivation, aeson, array, base, binary, blaze-html, blaze-markup, bytestring
, containers, data-default, deepseq, directory, file-embed, filepath, fsnotify
, hashable, http-conduit, http-types, lib, lifted-async, lrucache, mtl
, network-uri, optparse-applicative, pandoc, parsec, process, QuickCheck, random
, regex-tdfa, resourcet, scientific, tagsoup, tasty, tasty-golden, tasty-hunit
, tasty-quickcheck, template-haskell, text, time, time-locale-compat
, unordered-containers, utillinux, vector, wai, wai-app-static, warp, yaml }:
mkDerivation {
  pname = "hakyll";
  version = "4.14.1.0";
  sha256 = "ec4a6d242b6f5aaebac9c7cd4ca6fb61d259eb28fba54ae66c807f44983b1ee8";
  isLibrary = true;
  isExecutable = true;
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    aeson
    array
    base
    binary
    blaze-html
    blaze-markup
    bytestring
    containers
    data-default
    deepseq
    directory
    file-embed
    filepath
    fsnotify
    hashable
    http-conduit
    http-types
    lifted-async
    lrucache
    mtl
    network-uri
    optparse-applicative
    pandoc
    parsec
    process
    random
    regex-tdfa
    resourcet
    scientific
    tagsoup
    template-haskell
    text
    time
    time-locale-compat
    unordered-containers
    vector
    wai
    wai-app-static
    warp
    yaml
  ];
  executableHaskellDepends = [ base directory filepath ];
  testHaskellDepends = [
    base
    bytestring
    containers
    filepath
    QuickCheck
    tasty
    tasty-golden
    tasty-hunit
    tasty-quickcheck
    text
    unordered-containers
    yaml
  ];
  testToolDepends = [ utillinux ];
  homepage = "http://jaspervdj.be/hakyll";
  description = "A static website compiler library";
  license = lib.licenses.bsd3;
}
