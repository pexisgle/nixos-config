# Explicit args (no <nixpkgs> fallback): called via callPackage from flake overlay.
# Upstream-first: this fork tracks pol-rivero/github-desktop-plus; re-check each
# nixpkgs bump whether upstream github-desktop suffices before updating hashes.
{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  github-desktop,
  git,
  git-lfs,
}:

let
  version = "3.6.5.0";

  customSrc = fetchFromGitHub {
    owner = "pol-rivero";
    repo = "github-desktop-plus";
    rev = "v${version}";

    fetchSubmodules = true;

    hash = "sha256-BjU5gGglRe6uIgK9srDzSliV8OlyURXQIEw+lhlGTQ0=";
  };

  customFetchYarnDeps =
    args:
    fetchYarnDeps (
      args
      // {
        hash =
          if lib.hasSuffix "app/yarn.lock" (builtins.toString args.yarnLock) then
            "sha256-ecvx5bPBJmVq9H8msRGNF/PoJgd8o7zZR2TCkgZQCMM="
          else
            "sha256-eijkCdG69X8Gm79kSq5zcRTQaWaf/5d8IL3y0a6zLrw=";
      }
    );

in
(github-desktop.override {
  fetchYarnDeps = customFetchYarnDeps;
}).overrideAttrs
  (oldAttrs: {
    pname = "github-desktop-plus";
    inherit version;
    src = customSrc;

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace script/build.ts \
        --replace-fail "import { removeCurlVersionRequirements } from './remove-curl-version-requirements'" "" \
        --replace-fail '    removeCurlVersionRequirements(gitDir)' '    // Nix replaces the bundled Git in postFixup.'
    '';

    postFixup = (oldAttrs.postFixup or "") + ''
      echo "Finalizing Git environment for NixOS (Corrected Paths)..."

      APP_GIT_DIR=$out/share/github-desktop/resources/app/git
      PLUS_TOOLS=$out/share/github-desktop/plus-tools
      mkdir -p $PLUS_TOOLS

      cp $APP_GIT_DIR/libexec/git-core/git-credential-desktop $PLUS_TOOLS/ || true
      find $APP_GIT_DIR -name "*desktop*" -exec cp {} $PLUS_TOOLS/ \;

      rm -rf $APP_GIT_DIR
      mkdir -p $APP_GIT_DIR/bin $APP_GIT_DIR/libexec/git-core

      ln -s ${git}/bin/git $APP_GIT_DIR/bin/git
      ln -s ${git}/libexec/git-core/* $APP_GIT_DIR/libexec/git-core/

      cp $PLUS_TOOLS/* $APP_GIT_DIR/libexec/git-core/
      ln -s $APP_GIT_DIR/libexec/git-core/git-credential-desktop $APP_GIT_DIR/bin/git-credential-desktop

      wrapProgram $out/bin/github-desktop \
        --prefix PATH : "$APP_GIT_DIR/bin:${
          lib.makeBinPath [
            git
            git-lfs
          ]
        }" \
        --set GIT_EXEC_PATH "$APP_GIT_DIR/libexec/git-core" \
        --set GIT_SSL_CAINFO "/etc/ssl/certs/ca-certificates.crt"

      rm -f $out/share/icons/hicolor/512x512/apps/github-desktop.png
      ACTUAL_ICON=$(find $out/share/github-desktop/resources/app/static -type f \( -name "*icon*.png" -o -name "*logo*.png" \) | sort | head -n 1)
      if [ -n "$ACTUAL_ICON" ]; then
        ln -s "$ACTUAL_ICON" $out/share/icons/hicolor/512x512/apps/github-desktop.png
      fi
    '';
  })
