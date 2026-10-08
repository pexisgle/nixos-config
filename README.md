# nixos-config

Pexisgle用の NixOS Flake 設定です。1つのリポジトリで desktop / laptop の2ホストを管理し、Home Manager を統合しています。

- 新ホストでは `secrets/common.yaml` を復号できる age 鍵（`flake.nix` の `sopsPaths.ageKeyFile`）を配置し、`nix run nixpkgs#cachix -- use pexisgle` でキャッシュを有効化してください（詳細は「バイナリキャッシュ」）。
- 切り戻しは世代選択で行います。GC（daily、`nh clean` による `--keep 5 --keep-since 3d`）より前の世代には戻れないため、直前の世代番号を控えておくと安全です。

## 構成

```
flake.nix                 # inputs / overlay / 2ホスト配線 / 共有定数（sopsPaths）
hosts/
  desktop/                # マシン固有: configuration.nix + gpu.nix + gaming.nix + home.nix
  laptop/                 #            configuration.nix + home.nix
modules/                  # 両ホスト共通
  nixos.nix               # ★ NixOS 側の入口マニフェスト（import 一覧）
  home.nix                # ★ Home Manager 側の入口マニフェスト + グローバル設定
  system/                 # boot / nix / nh / caches / secrets / users / tmp / atd / docker
  networking/             # network（NM/Bluetooth/firewall） / vpn / ssh
  i18n/                   # locale / input-method（fcitx5 + hazkey） / hazkey（Zenzai GPU シード）
  desktop/                # session / fonts（NixOS） + niri / dms / xdg（HM）
  hardware/amdgpu.nix
  dev/                    # shell / tools / vscode（HM） + opencode / opencodex（+ plugins）
  apps/                   # browsers / communication / media（HM）
packages/                 # 自作パッケージ（github-desktop-plus.nix）
scripts/                  # update.sh / update-github-desktop-plus.sh / check-caches.sh
secrets/                  # sops 暗号文（.sops.yaml はルート据え置き）
.github/workflows/        # CI（cache / update）
```

### どこに置くか

| 対象 | 置き場所 |
|---|---|
| 両ホスト共通の設定 | `modules/<領域>/`（例: VPN と SSH はどちらも `modules/networking/`） |
| NixOS 用か Home Manager 用か | `modules/nixos.nix` / `modules/home.nix` の import 一覧で表現（唯一の真実） |
| 特定ホストのみ | `hosts/<host>/`（desktop 専用の Steam/Sunshine は `hosts/desktop/gaming.nix`） |
| 自作パッケージ | `packages/` |
| 秘密情報 | `secrets/` |

## 前提

- NixOS（flakes有効）
- `sudo` 権限

## 使い方

リポジトリ直下で実行します（`programs.nh.flake` が設定されているため、`nh os switch` も利用可能です）。

### Desktop に反映

```bash
# nh を使用する場合（ホスト自動判別）
nh os switch

# または nixos-rebuild を直接使用する場合
sudo nixos-rebuild switch --flake .#pexisgle-desktop
```

### Laptop に反映

```bash
# nh を使用する場合（ホスト自動判別）
nh os switch

# または nixos-rebuild を直接使用する場合
sudo nixos-rebuild switch --flake .#pexisgle-laptop
```

### ビルド確認のみ

```bash
nix build .#nixosConfigurations.pexisgle-desktop.config.system.build.toplevel .#nixosConfigurations.pexisgle-laptop.config.system.build.toplevel
nix flake check --no-build   # 評価チェック
nix run --inputs-from . nixpkgs#nixfmt -- --check $(git ls-files '*.nix')   # フォーマット確認（修正は nix fmt）
```

## バイナリキャッシュ

自作・ローカル改変のある派生（`github-desktop-plus`、llm-agents 由来パッケージなど）は `cache.nixos.org` に存在しないため、リポジトリ所有の Cachix キャッシュで補います。

### キャッシュリストの単一ソース

- `flake.nix` の `nixConfig`（Nix が完全評価せず読むため**リテラル必須**）
- `modules/system/caches.nix`（NixOS 側 `modules/system/nix.nix` が参照するミラー）
- `scripts/check-caches.sh` が両者の一致を検証（CI も実行）

### リポジトリ Cachix キャッシュ（pexisgle）

`.github/workflows/cache.yml` が main への push で両ホストのシステムクロージャをビルドし、`CACHIX_AUTH_TOKEN` があれば `pexisgle` キャッシュへアップロードします。トークン未設定でもビルド検証だけは実行されます。

各有効化:

```sh
nix run nixpkgs#cachix -- use pexisgle
```

### Numtide キャッシュ

`numtide/llm-agents.nix` 由来のパッケージ（`opencodex` / `chatgpt` / `opencode2` / `opencode2-desktop` / `command-code`）は `https://cache.numtide.com` から取得します。

### FlakeHub Cache（CI）

`cache.yml` / `update.yml` は FlakeHub Cache も併用し、GitHub Actions 内の中間ストアパスをキャッシュします。

### 上流キャッシュ

Numtide / niri / lanzaboote / quickshell などの上流キャッシュは `flake.nix` の `nixConfig` と `modules/system/nix.nix` の両方に設定されています。

## 更新

`flake.lock` を更新する場合:

```bash
nix flake update
```

更新後は `nixos-rebuild` で適用してください。

### 自動更新 (GitHub Actions)

`.github/workflows/update.yml` が毎週月曜 09:00 (JST) に `flake.lock` の更新 (`nix flake update`) を実行し、変更があれば自動でPRを作ります。

Antigravity（Hub / CLI）は [Hy4ri/antigravity-flake](https://github.com/Hy4ri/antigravity-flake) Flake および nixpkgs から提供されているため、`nix flake update` で同時に最新版に更新されます。

`opencodex` / `chatgpt` / `opencode2` / `opencode2-desktop` / `command-code` は [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix) から取得しており、同様に `nix flake update`（または `nix flake update llm-agents`）で更新されます。

PRがマージされた後、ホスト側で `nixos-rebuild switch --flake .#pexisgle-desktop` (または laptop) を実行して反映してください。

### ローカルから手動で実行

CIと同じ処理をローカルで走らせるラッパー:

```bash
./scripts/update.sh                # flake.lock + 自作パッケージの更新
DRY_RUN=1 ./scripts/update.sh      # 変更を破棄して確認だけ
```

## メモ

- Home Manager は NixOS モジュールとして統合されています。
- 共通設定を変更した場合、desktop / laptop の両方に影響します。
- `lanzaboote` を使っているため、Secure Boot関連の運用は環境に合わせて確認してください（`/var/lib/sbctl` に PKI を保持）。
