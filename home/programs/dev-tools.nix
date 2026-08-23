{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcr
    kitty
    tmux
    xwayland-satellite
    nixd
    nixfmt
    gh
    devenv
    mise
    bun
    nodejs
    rtk
    # Search, navigation, and structural code queries
    ripgrep
    fd
    ast-grep
    fzf
    zoxide
    broot

    # Modern command-line replacements and file utilities
    bat
    eza
    sd
    dust
    duf
    procs
    tealdeer
    yazi
    ouch
    jless

    # Development workflow utilities
    delta
    tokei
    hyperfine
    just
    watchexec
    xh
    jq
    zed-editor-fhs
    opencode-desktop
    opencode2
    github-desktop-plus
    antigravity
    antigravity-cli
    code-cursor-fhs
    grok-bot
    python3Packages.huggingface-hub
  ];
}
