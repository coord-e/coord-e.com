{ mkDerivation, base, binary, blaze-html, bytestring, containers, directory
, filepath, lib, pretty-show, skylighting-core, text }:
mkDerivation {
  pname = "skylighting";
  version = "0.10.1";
  sha256 = "bb840ebcacb653842f2196faaf1874c326849b3de7bd95f61dd72fc0c635ee7e";
  configureFlags = [ "-fexecutable" ];
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends =
    [ base binary bytestring containers skylighting-core ];
  executableHaskellDepends = [
    base
    blaze-html
    bytestring
    containers
    directory
    filepath
    pretty-show
    text
  ];
  homepage = "https://github.com/jgm/skylighting";
  description = "syntax highlighting library";
  license = lib.licenses.gpl2Only;
}
