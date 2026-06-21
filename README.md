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

### 自動更新 (GitHub Actions)

`.github/workflows/update.yml` が毎週月曜 09:00 (JST) に以下を順番に実行し、変更があれば自動でPRを作ります。

- `pkgs/antigravity-hub/sources.json` の更新
- `pkgs/antigravity-cli/package.nix` の更新
- `flake.lock` の更新 (`nix flake update`)

手動実行も可能: Actions タブ → "update" → Run workflow → `target` を選択。

- `all` (デフォルト): 全パッケージ + flake
- `antigravity-hub`: hub のみ
- `antigravity-cli`: cli のみ
- `flake`: flake.lock のみ

PRがマージされた後、ホスト側で `nixos-rebuild switch --flake .#pexisgle-desktop` (または laptop) を実行して反映してください。

### ローカルから手動で実行

CIと同じ処理をローカルで走らせるラッパー:

```bash
./scripts/update.sh                # 全パッケージ + flake
./scripts/update.sh antigravity-hub
./scripts/update.sh antigravity-cli
./scripts/update.sh flake
DRY_RUN=1 ./scripts/update.sh      # 変更を破棄して確認だけ
```

## メモ

- Home Manager は NixOS モジュールとして統合されています。
- 共通設定を変更した場合、desktop / laptop の両方に影響します。
- `lanzaboote` を使っているため、Secure Boot関連の運用は環境に合わせて確認してください。
