{
  stdenvNoCC,
  fetchurl,
  gnutar,
}:

stdenvNoCC.mkDerivation {
  pname = "node-addon-api";
  version = "8.9.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-8.9.2.tgz";
    sha256 = "1sn8jz8wvkhw395q5f29fyfirvf609fc47cgg4zs668vajc5dmjc";
  };

  nativeBuildInputs = [ gnutar ];
  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/node_modules/node-addon-api
    tar -xzf $src -C $out/lib/node_modules/node-addon-api --strip-components=1
  '';
}
