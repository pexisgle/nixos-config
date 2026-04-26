# nixos-config

Pexisgle用の NixOS Flake 設定です。1つのリポジトリで desktop / laptop の2ホストを管理し、Home Manager を統合しています。

## 構成

- `flake.nix`
  - `nixosConfigurations.pexisgle-desktop`
  - `nixosConfigurations.pexisgle-laptop`
- `modules/common.nix`
  - 共通の NixOS 設定（lanzaboote, locale, フォント, 入力メソッドなど）
- `hosts/desktop/configuration.nix`
  - デスクトップ固有設定（NVIDIA）
- `hosts/laptop/configuration.nix`
  - ラップトップ固有設定（amdgpu）
- `home/common.nix`
  - 共通の Home Manager 設定（zsh, vscode, direnv, DMS/niri など）
- `home/desktop.nix`, `home/laptop.nix`
  - ホスト別 Home Manager エントリ
- `pkgs/github-desktop-plus.nix`
  - カスタムパッケージ

## 前提

- NixOS（flakes有効）
- `sudo` 権限

## 使い方

リポジトリ直下で実行します。

### Desktop に反映

```bash
sudo nixos-rebuild switch --flake .#pexisgle-desktop
```

### Laptop に反映

```bash
sudo nixos-rebuild switch --flake .#pexisgle-laptop
```

### ビルド確認のみ

```bash
nix build .#nixosConfigurations.pexisgle-desktop.config.system.build.toplevel
nix build .#nixosConfigurations.pexisgle-laptop.config.system.build.toplevel
```

## 更新

`flake.lock` を更新する場合:

```bash
nix flake update
```

更新後は `nixos-rebuild` で適用してください。

## メモ

- Home Manager は NixOS モジュールとして統合されています。
- 共通設定を変更した場合、desktop / laptop の両方に影響します。
- `lanzaboote` を使っているため、Secure Boot関連の運用は環境に合わせて確認してください。
