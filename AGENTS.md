# AGENTS.md

このファイルは、本リポジトリ（`nixos-config`）で作業を行う AI エージェント（Antigravity, OpenCode, Claude Code 等）向けの作業ガイドラインです。

---

## 1. フォーマット・コードスタイル

コードの変更を行った後は、必ずフォーマットを実行または検証してください。

- **フォーマット適用**:
  ```bash
  nix fmt
  ```
- **フォーマット差分チェック（CI同等）**:
  ```bash
  nix fmt -- --check
  ```
- **特定ファイルのみフォーマット**:
  ```bash
  nix fmt -- path/to/file.nix
  ```

> [!NOTE]
> `flake.nix` 内の `formatter.x86_64-linux` はラッパースクリプト（`pkgs.writeShellApplication`）として定義されています。引数なしで実行された場合は `git ls-files '*.nix'` を自動的に収集して `nixfmt` に渡すため、標準入力待ちでハングすることなく直感的にフォーマットを実行できます。

---

## 2. 構文・評価チェック

設定を変更した後は、構文エラーや型エラーがないかをチェックしてください。

```bash
# flake 全体の評価チェック（パッケージビルドは行わないため高速）
nix flake check --no-build

# 各ホストのビルド確認
nix build .#nixosConfigurations.pexisgle-laptop.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.pexisgle-desktop.config.system.build.toplevel --no-link
```

---

## 3. ファイル配置とアーキテクチャ規約

| 区分 | 配置場所 | 備考 |
|---|---|---|
| 両ホスト共通の NixOS / HM 設定 | `modules/<領域>/` | `modules/nixos.nix` または `modules/home.nix` で import |
| Desktop 専用（NixOS） | `hosts/desktop/nixos/<機能>.nix` | `hosts/desktop/configuration.nix` で import |
| Desktop 専用（Home Manager） | `hosts/desktop/home/<機能>.nix` | `hosts/desktop/home.nix` で import |
| Laptop 専用（NixOS） | `hosts/laptop/nixos/<機能>.nix` | `hosts/laptop/configuration.nix` で import |
| Laptop 専用（Home Manager） | `hosts/laptop/home/<機能>.nix` | `hosts/laptop/home.nix` で import |
| パッケージ定義 | `packages/<pkg>.nix` | `flake.nix` の `customPackagesOverlay` で配線 |
| 秘密情報 | `secrets/common.yaml` | sops + age で暗号化 |

- **単一の真実**: 新しいモジュールを追加した際は、必ず対応する入口マニフェスト（`modules/nixos.nix` や `modules/home.nix`、あるいは各ホストの `configuration.nix` / `home.nix`）に追記してください。
- **キャッシュ設定の同期**: `flake.nix` の `nixConfig` と `modules/system/caches.nix` の両方を常に同期させてください（`scripts/check-caches.sh` で検証可能）。

---

## 4. 秘密情報（sops-nix）の扱い

- シークレットは `secrets/common.yaml` で age 暗号化されています。
- 平文の秘密情報をコミットに含めないでください。
- 復号・編集には `sops` コマンド（または `nix shell nixpkgs#sops`）を使用し、鍵は `sopsPaths.ageKeyFile`（`/home/pexisgle/.config/sops/age/keys.txt`）を参照します。

---

## 5. 反映コマンド

```bash
# 推奨: nh を使用（ホスト自動判別）
nh os switch

# または nixos-rebuild を使用
sudo nixos-rebuild switch --flake .#pexisgle-laptop
```
