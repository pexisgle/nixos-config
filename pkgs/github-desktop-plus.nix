{ pkgs ? import <nixpkgs> {} }:

let
  version = "3.5.9.0";
  
  customSrc = pkgs.fetchFromGitHub {
    owner = "pol-rivero";
    repo = "github-desktop-plus";
    rev = "v${version}";
    # 【重要】絵文字データの取得に必須
    fetchSubmodules = true; 
    # ハッシュを変更したので、一度ここを空文字にして 
    # nix-build を実行し、出力された新しいハッシュを貼り付けてください
    hash = "sha256-p3Pxa4JnCKAg03u0QhSuBBIA4OcdvL1UplPot/9Y0Yo="; 
  };

  # パッケージ内部で呼ばれる fetchYarnDeps を上書きするフック
  customFetchYarnDeps = args: pkgs.fetchYarnDeps (args // {
    hash = 
      if pkgs.lib.hasSuffix "app/yarn.lock" (builtins.toString args.yarnLock)
      then "sha256-eU5bmO45tvx6Bk4AyySfbSQNcQcxXeicoKliMZ3BLvo="  # サブ
      else "sha256-4LY0dcvGVIf25q7C+5TE+/mO07BP/blU16vZf8xB1Y4="; # メイン
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
    
    # 1. パスの定義
    APP_GIT_DIR=$out/share/github-desktop/resources/app/git
    PLUS_TOOLS=$out/share/github-desktop/plus-tools
    mkdir -p $PLUS_TOOLS

    # 2. ログに基づいた正確な場所から独自ツールを救出
    # git-credential-desktop は libexec/git-core の中にあります
    cp $APP_GIT_DIR/libexec/git-core/git-credential-desktop $PLUS_TOOLS/ || true
    # その他、desktopと名のつくバイナリを全て救出
    find $APP_GIT_DIR -name "*desktop*" -exec cp {} $PLUS_TOOLS/ \;

    # 3. ディレクトリを再構築（シンボリックリンクの階層エラーを避けるため構造を丁寧に作る）
    rm -rf $APP_GIT_DIR
    mkdir -p $APP_GIT_DIR/bin $APP_GIT_DIR/libexec/git-core

    # 4. NixOSのGitをリンク
    ln -s ${pkgs.git}/bin/git $APP_GIT_DIR/bin/git
    ln -s ${pkgs.git}/libexec/git-core/* $APP_GIT_DIR/libexec/git-core/

    # 5. 救出した Plus独自のツールを本物のGitの隣に戻す
    cp $PLUS_TOOLS/* $APP_GIT_DIR/libexec/git-core/
    # Gitがサブコマンドとして認識できるように bin にもリンクを貼る
    ln -s $APP_GIT_DIR/libexec/git-core/git-credential-desktop $APP_GIT_DIR/bin/git-credential-desktop

    # 6. 実行バイナリの最終ラップ（証明書とパスの固定）
    wrapProgram $out/bin/github-desktop \
      --prefix PATH : "$APP_GIT_DIR/bin:${pkgs.lib.makeBinPath [ pkgs.git pkgs.git-lfs ]}" \
      --set GIT_EXEC_PATH "$APP_GIT_DIR/libexec/git-core" \
      --set GIT_SSL_CAINFO "/etc/ssl/certs/ca-certificates.crt"

    # 7. アイコンの修正
    rm -f $out/share/icons/hicolor/512x512/apps/github-desktop.png
    ACTUAL_ICON=$(find $out/share/github-desktop/resources/app/static -type f -name "*icon*.png" -o -name "*logo*.png" | head -n 1)
    if [ -n "$ACTUAL_ICON" ]; then
      ln -s "$ACTUAL_ICON" $out/share/icons/hicolor/512x512/apps/github-desktop.png
    fi
  '';
})