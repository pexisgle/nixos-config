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
  runCommand,
}:

let
  version = "3.6.7.1";

  # Updated by scripts/update-github-desktop-plus.sh (named hashes are its targets).
  srcHash = "sha256-8xQeaHFJbhtozJIgL0UUyzSn6GCvgPZLEpheAPqztmo=";
  rootYarnHash = "sha256-gGrbqBJ9W3Xo+5ptUff+wivjZBU/bPj+b8Ory7X1ImA=";
  appYarnHash = "sha256-JSpeuHigOribcaQEu9MG0L1+eLSZHe0/M0FVjwX1WCU=";

  customSrc = fetchFromGitHub {
    owner = "pol-rivero";
    repo = "github-desktop-plus";
    rev = "v${version}";

    fetchSubmodules = true;

    hash = srcHash;
  };

  # The fork's lockfiles may record @electron/* resolved URLs on Microsoft's
  # 1ES feed, which prefetch-yarn-deps cannot fetch. Rewrite them to the public
  # npm registry: tarball contents (and integrity hashes) are identical.
  # Keep this sed in sync with scripts/update-github-desktop-plus.sh.
  patchedLocks = runCommand "github-desktop-plus-yarn-locks" { } ''
    mkdir -p $out/app
    cp -f ${customSrc}/yarn.lock $out/yarn.lock
    cp -f ${customSrc}/app/yarn.lock $out/app/yarn.lock
    sed -i -E \
      's|https://[A-Za-z0-9.-]*\.pkgs\.visualstudio\.com/[^[:space:]]*/registry/|https://registry.npmjs.org/|g' \
      $out/yarn.lock $out/app/yarn.lock
  '';

  customFetchYarnDeps =
    args:
    let
      isAppLock = lib.hasSuffix "app/yarn.lock" (builtins.toString args.yarnLock);
    in
    fetchYarnDeps (
      args
      // {
        yarnLock = if isAppLock then "${patchedLocks}/app/yarn.lock" else "${patchedLocks}/yarn.lock";
        hash = if isAppLock then appYarnHash else rootYarnHash;
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
      # Keep the build's lockfiles consistent with patchedLocks above, so the
      # offline yarn cache keys match. Same sed as patchedLocks / the updater.
      sed -i -E \
        's|https://[A-Za-z0-9.-]*\.pkgs\.visualstudio\.com/[^[:space:]]*/registry/|https://registry.npmjs.org/|g' \
        yarn.lock app/yarn.lock

      substituteInPlace script/build.ts \
        --replace-fail "import { removeCurlVersionRequirements } from './remove-curl-version-requirements'" "" \
        --replace-fail '    removeCurlVersionRequirements(gitDir)' '    // Nix replaces the bundled Git in postFixup.'

      # Upstream 3.6.7.1 added verify-symlinks which rejects non-relocatable
      # symlinks (such as absolute Nix store paths to git-core). Stub it out.
      if [ -f script/verify-symlinks.ts ]; then
        echo "export function assertRelocatableSymlinks(_root: string): void {}" > script/verify-symlinks.ts
      fi
    '';

    postInstall = (oldAttrs.postInstall or "") + ''
      # The 3.6.7.0 static-resource copy leaves absolute /build symlinks for a
      # few gitignore aliases (e.g. Clojure.gitignore -> Leiningen.gitignore),
      # which fail fixup's noBrokenSymlinks check once installed. The targets
      # exist only inside the build tree, so materialize any link pointing
      # there while /build still exists.
      for link in $(find "$out/share/github-desktop/resources/app/static" -type l); do
        target="$(readlink "$link")"
        case "$target" in
          "$NIX_BUILD_TOP"/*)
            cp --remove-destination -f "$target" "$link"
            ;;
        esac
      done
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
