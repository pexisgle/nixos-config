{
  symlinkJoin,
  makeWrapper,
  dsh-unwrapped,
}:

symlinkJoin {
  name = "dsh-${dsh-unwrapped.version}";
  paths = [ dsh-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    rm "$out/bin/dsh"
    makeWrapper "${dsh-unwrapped}/bin/dsh" "$out/bin/dsh" \
      --run 'if [ "$#" -eq 0 ]; then set -- web; fi'
    ln -s dsh "$out/bin/deepseek-harness"
  '';
}
