# nixos-config

- 新ホストでは `secrets/common.yaml` を復号できる age 鍵（`lib/sops.nix` のパス）を配置し、`nix run nixpkgs#cachix -- use pexisgle` でキャッシュを有効化してください（詳細は `docs/binary-cache.md`）。
- 切り戻しは世代選択で行います。GC（daily、`--delete-older-than 3d`）より前の世代には戻れないため、直前の世代番号を控えておくと安全です。
Pexisgle用の NixOS Flake 設定です。1つのリポジトリで desktop / laptop の2ホストを管理し、Home Manager を統合しています。

## 構成

- `flake.nix`
  - `nixosConfigurations.pexisgle-desktop` / `pexisgle-laptop`（2ホスト構成は維持）
  - `formatter.x86_64-linux`（`nix fmt` 用）
- `lib/caches.nix` / `lib/sops.nix`
  - binary cache と sops パスの一元定義（flake と NixOS/Home 両方から参照）
- `modules/common.nix`
  - 共通の NixOS 設定（`core/*`: boot/nix/network/secrets/vpn/docker/tmp、`desktop/*`: base/locale/fonts、`hardware/amdgpu-base.nix`、`gaming/steam.nix`）
- `hosts/desktop/configuration.nix`
  - デスクトップ固有設定（ROCm、RDNA4 kernelParams、Vulkan 開発パッケージ、swapfile）
- `hosts/laptop/configuration.nix`
  - 薄いラップトップ差分（amdgpu 基盤は共通化済み。将来の laptop 固有設定用）
- `home/common.nix` + `home/programs/*`
  - 共通の Home Manager 設定（shell は `programs.*` 統合、dev-tools は用途別に分類）
- `home/desktop.nix`, `home/laptop.nix`
  - 薄いホスト別エントリ（現在は共通のみ。将来の差分用）
- `pkgs/github-desktop-plus.nix` / `pkgs/opencodex.nix`（+ `pkgs/opencodex/package.json`・`package-lock.json`）
  - 自作パッケージ（引数明示化済み。上流で代替可能かは更新時に再評価）
- `scripts/update*.sh` / `.github/workflows/`
  - 更新自動化と CI（fmt + flake check → 両 toplevel ビルド → 自動 PR）
- `docs/` / `secrets/common.yaml`（sops 暗号化） / `skills/`

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
nix build .#nixosConfigurations.pexisgle-desktop.config.system.build.toplevel .#nixosConfigurations.pexisgle-laptop.config.system.build.toplevel
nix flake check --no-build   # 評価チェック
nix run --inputs-from . nixpkgs#nixfmt -- --check $(git ls-files '*.nix')   # フォーマット確認（修正は nix fmt）
```

## 更新

`flake.lock` を更新する場合:

```bash
nix flake update
```

更新後は `nixos-rebuild` で適用してください。

### 自動更新 (GitHub Actions)

`.github/workflows/update.yml` が毎週月曜 09:00 (JST) に `flake.lock` の更新 (`nix flake update`) を実行し、変更があれば自動でPRを作ります。

Antigravity（Hub / CLI）は [Hy4ri/antigravity-flake](https://github.com/Hy4ri/antigravity-flake) Flake および nixpkgs から提供されているため、`nix flake update` で同時に最新版に更新されます。

PRがマージされた後、ホスト側で `nixos-rebuild switch --flake .#pexisgle-desktop` (または laptop) を実行して反映してください。

### ローカルから手動で実行

CIと同じ処理をローカルで走らせるラッパー:

```bash
./scripts/update.sh                # flake.lock の更新
DRY_RUN=1 ./scripts/update.sh      # 変更を破棄して確認だけ
```

## メモ

- Home Manager は NixOS モジュールとして統合されています。
- 共通設定を変更した場合、desktop / laptop の両方に影響します。
- `lanzaboote` を使っているため、Secure Boot関連の運用は環境に合わせて確認してください（`/var/lib/sbctl` に PKI を保持）。
