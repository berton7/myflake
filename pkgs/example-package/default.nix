{ stdenv }:

stdenv.mkDerivation rec {
  pname = "example-package";
  version = "1.0";
  src = ./.;
  buildPhase = "echo echo Hello World > example";
  installPhase = "
    mkdir -p $out/bin
    install -Dm755 example $out/bin
  ";
}
