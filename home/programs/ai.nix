{ pkgs, ... }:

let
  pythonForComfy = pkgs.python312;

  comfyui-uv = pkgs.writeShellApplication {
    name = "comfyui";

    runtimeInputs = with pkgs; [
      git
      uv
      pythonForComfy
      stdenv.cc.cc.lib
      glib
      libGL
      zlib
      zstd
      numactl
    ];

    text = ''
      COMFY_DIR="''${COMFY_DIR:-$HOME/.local/share/comfyui}"
      ROCM_VERSION="''${ROCM_VERSION:-rocm6.2}"

      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [
        stdenv.cc.cc.lib
        glib
        libGL
        zlib
        zstd
        numactl
        libffi
        openssl
      ])}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      if [[ -d "/run/opengl-driver/lib" ]]; then
        export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
      fi

      echo "=== ComfyUI Runner (uv) ==="

      if [[ ! -d "$COMFY_DIR/.git" ]]; then
        echo "Cloning ComfyUI to $COMFY_DIR..."
        mkdir -p "$(dirname "$COMFY_DIR")"
        git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
      fi

      cd "$COMFY_DIR"

      # PyTorch が対応している Python 3.12 で venv を作成・更新
      if [[ ! -d "$COMFY_DIR/.venv" ]] || ! "$COMFY_DIR/.venv/bin/python" --version 2>&1 | grep -q "3.12"; then
        echo "Creating Python 3.12 virtual environment with uv..."
        rm -rf "$COMFY_DIR/.venv"
        uv venv --python "${pythonForComfy}/bin/python" "$COMFY_DIR/.venv"
      fi

      # shellcheck disable=SC1091
      source "$COMFY_DIR/.venv/bin/activate"

      if ! python -c "import torch; print('PyTorch Version:', torch.__version__)" &>/dev/null; then
        echo "Installing ROCm PyTorch and dependencies with uv..."
        uv pip install torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$ROCM_VERSION"
        uv pip install -r requirements.txt
      fi

      echo "Starting ComfyUI..."
      exec python main.py "$@"
    '';
  };
in
{
  home.packages = [
    pkgs.uv
    comfyui-uv
  ];
}
