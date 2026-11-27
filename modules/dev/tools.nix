{ pkgs, ... }:

{
  # Agy Powertools attaches over CDP, and its installer only patches
  # /usr/share/applications/antigravity.desktop, which NixOS does not have.
  # Ship an already-flagged launcher where both powertools and the desktop
  # look first, so the flag is present and powertools never rewrites this file.
  home.file.".local/share/applications/antigravity.desktop".text = ''
    [Desktop Entry]
    Name=Antigravity
    Exec=${pkgs.antigravity}/bin/antigravity --remote-debugging-port=0 %u
    Icon=antigravity
    Type=Application
    Categories=Development;
    Comment=Google Antigravity Desktop Hub
    MimeType=x-scheme-handler/antigravity;
  '';

  home.packages = with pkgs; [
    kitty
    tmux

    nixd
    nixfmt

    gh

    mise
    bun

    # DSH のプラグイン市場は PATH 上の pnpm を起動して profile を更新する。
    # deepseek-harness-desktop は同梱の pnpm v10 を意図的に PATH から外している
    # (packages/deepseek-harness-desktop.nix) ので、ここで pnpm を供給する。
    # profile の storeDir は store/v11 なので、メジャーは 11 系に固定する
    # (12 系に上げる場合は store の作り直しが必要)。
    pnpm_11

    rtk

    # file-search skill が想定する検索ツール一式。
    ripgrep
    fd
    ast-grep
    semgrep
    ripgrep-all
    tokei
    scc
    jq

    just

    serena

    zed-editor-fhs
    github-desktop-plus
    antigravity
    antigravity-cli
    dsh
    deepseek-harness-desktop
  ];
}
