{ pkgs ? import <nixpkgs> {} }:

let
  version = "3.5.9.0";
  
  customSrc = pkgs.fetchFromGitHub {
    owner = "pol-rivero";
    repo = "github-desktop-plus";
    rev = "v${version}";
    
    fetchSubmodules = true; 
    
    
    hash = "sha256-p3Pxa4JnCKAg03u0QhSuBBIA4OcdvL1UplPot/9Y0Yo="; 
  };

  
  customFetchYarnDeps = args: pkgs.fetchYarnDeps (args // {
    hash = 
      if pkgs.lib.hasSuffix "app/yarn.lock" (builtins.toString args.yarnLock)
      then "sha256-eU5bmO45tvx6Bk4AyySfbSQNcQcxXeicoKliMZ3BLvo="  
      else "sha256-4LY0dcvGVIf25q7C+5TE+/mO07BP/blU16vZf8xB1Y4="; 
  });

in
(pkgs.github-desktop.override {
  fetchYarnDeps = customFetchYarnDeps;
}).overrideAttrs (oldAttrs: {
  pname = "github-desktop-plus";
  inherit version;
  src = customSrc;

  postFixup = (oldAttrs.postFixup or "") + ''
    echo "Finalizing Git environment for NixOS (Corrected Paths)..."
    
    APP_GIT_DIR=$out/share/github-desktop/resources/app/git
    PLUS_TOOLS=$out/share/github-desktop/plus-tools
    mkdir -p $PLUS_TOOLS

    cp $APP_GIT_DIR/libexec/git-core/git-credential-desktop $PLUS_TOOLS/ || true
    find $APP_GIT_DIR -name "*desktop*" -exec cp {} $PLUS_TOOLS/ \;

    rm -rf $APP_GIT_DIR
    mkdir -p $APP_GIT_DIR/bin $APP_GIT_DIR/libexec/git-core

    ln -s ${pkgs.git}/bin/git $APP_GIT_DIR/bin/git
    ln -s ${pkgs.git}/libexec/git-core/* $APP_GIT_DIR/libexec/git-core/

    cp $PLUS_TOOLS/* $APP_GIT_DIR/libexec/git-core/
    ln -s $APP_GIT_DIR/libexec/git-core/git-credential-desktop $APP_GIT_DIR/bin/git-credential-desktop

    wrapProgram $out/bin/github-desktop \
      --prefix PATH : "$APP_GIT_DIR/bin:${pkgs.lib.makeBinPath [ pkgs.git pkgs.git-lfs ]}" \
      --set GIT_EXEC_PATH "$APP_GIT_DIR/libexec/git-core" \
      --set GIT_SSL_CAINFO "/etc/ssl/certs/ca-certificates.crt"

    rm -f $out/share/icons/hicolor/512x512/apps/github-desktop.png
    ACTUAL_ICON=$(find $out/share/github-desktop/resources/app/static -type f -name "*icon*.png" -o -name "*logo*.png" | head -n 1)
    if [ -n "$ACTUAL_ICON" ]; then
      ln -s "$ACTUAL_ICON" $out/share/icons/hicolor/512x512/apps/github-desktop.png
    fi
  '';
})