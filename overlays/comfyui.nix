{ comfyui-nix }:

final: prev:

let
  lib = final.lib;
  comfyuiNixPath = comfyui-nix.outPath;
  versions = import "${comfyuiNixPath}/nix/versions.nix";

  basePythonOverrides = import "${comfyuiNixPath}/nix/python-overrides.nix" {
    pkgs = final;
    inherit versions;
    gpuSupport = "rocm";
  };

  pythonOverrides = finalPy: prevPy:
    (basePythonOverrides finalPy prevPy) // {
      "gradio-client" = (prevPy."gradio-client" or finalPy."gradio-client").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "gradio" = (prevPy."gradio" or finalPy."gradio").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "comfyui-manager" = (prevPy."comfyui-manager" or finalPy."comfyui-manager").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "inline-snapshot" = (prevPy."inline-snapshot" or finalPy."inline-snapshot").overridePythonAttrs (_: {
        doCheck = false;
      });
      "mss" = (prevPy."mss" or finalPy."mss").overridePythonAttrs (_: {
        doCheck = false;
      });
    };

  python = final.python312.override {
    packageOverrides = pythonOverrides;
  };

  vendored = import "${comfyuiNixPath}/nix/vendored-packages.nix" {
    pkgs = final;
    inherit python versions;
  };

  gradioClientFixed = vendored.gradioClient.overridePythonAttrs (_: {
    dontCheckRuntimeDeps = true;
  });

  vendoredFixed = builtins.mapAttrs (name: pkg:
    if pkg != null && builtins.isAttrs pkg && pkg ? overridePythonAttrs then
      pkg.overridePythonAttrs (old: {
        dontCheckRuntimeDeps = true;
        propagatedBuildInputs = builtins.map (input:
          if (input.pname or "") == "gradio-client" then gradioClientFixed else input
        ) (
          (old.propagatedBuildInputs or [ ]) ++ (
            if name == "comfyuiManager" then
              with python.pkgs; [
                chardet
                gitpython
                huggingface-hub
                pygithub
                rich
                toml
                transformers
                typing-extensions
                typer
                uv
              ]
            else [ ]
          )
        );
      })
    else
      pkg
  ) vendored;

  customNodes = import "${comfyuiNixPath}/nix/custom-nodes.nix" {
    pkgs = final;
    inherit (final) lib;
    inherit python versions;
  };

  templateInputs = import "${comfyuiNixPath}/nix/template-inputs.nix" { pkgs = final; };

  bundledFonts = final.symlinkJoin {
    name = "comfyui-fonts";
    paths = with final; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      roboto
    ];
    postBuild = ''
      mkdir -p $out/ttf
      find $out/share/fonts \( -name "*.ttf" -o -name "*.TTF" \) -exec ln -sf {} $out/ttf/ \; 2>/dev/null || true
    '';
  };

  comfyuiSrcRaw = final.fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "ComfyUI";
    rev = versions.comfyui.rev;
    hash = versions.comfyui.hash;
  };
  comfyuiSrc = final.applyPatches {
    src = comfyuiSrcRaw;
    patches = [
      "${comfyuiNixPath}/nix/patches/comfyui-ltxvideo-compat.patch"
      "${comfyuiNixPath}/nix/patches/comfyui-cpu-fallback.patch"
    ];
  };

  modelDownloaderDir = "${comfyuiNixPath}/src/custom_nodes/model_downloader";

  pipConstraints = final.writeText "pip-constraints.txt" ''
    huggingface-hub<1.0
    transformers>=4.50.3
    torch>=2.0.0
    torchvision>=0.15.0
    numpy>=1.25.0
    pillow>=9.0.0
    safetensors>=0.4.2
    aiohttp>=3.11.8
    yarl>=1.18.0
    SQLAlchemy>=2.0.0
    av>=16.0.0
    simpleeval>=1.0.0
    comfyui-frontend-package==${versions.vendored.frontendPackage.version}
    comfyui-workflow-templates==${versions.vendored.workflowTemplates.version}
    comfyui-embedded-docs==${versions.vendored.embeddedDocs.version}
    comfyui-manager==${versions.vendored.manager.version}
    comfy-kitchen==${versions.vendored.comfyKitchen.version}
    comfy-aimdo==${versions.vendored.comfyAimdo.version}
    comfy-angle==${versions.vendored.comfyAngle.version}
    gradio-client==${versions.vendored.gradioClient.version}
    gradio==${versions.vendored.gradio.version}
    sageattention==${versions.vendored.sageattention.version}
  '';

  managerConfig = final.writeText "comfyui-manager-config.ini" ''
    [default]
    security_level = normal
    network_mode = personal_cloud
  '';

  pythonRuntimeFixed = python.withPackages (
    ps:
    let
      base = with ps; [
        pillow
        numpy
        einops
        transformers
        tokenizers
        sentencepiece
        safetensors
        aiohttp
        yarl
        pyyaml
        requests
        scipy
        tqdm
        psutil
        alembic
        sqlalchemy
        filelock
        av
        blake3
        pydantic-settings
        simpleeval
      ];
      extras =
        with ps;
        [
          pip
          uv
          chardet
          pygithub
          typer
          matrix-nio
          opencv4
          imageio-ffmpeg
          scikit-image
          piexif
          matplotlib
          dill
          segment-anything
          sam2
          ultralytics
          mss
          accelerate
          gguf
          protobuf
          diffusers
          huggingface-hub
          timm
          peft
          librosa
          torchdiffeq
          omegaconf
          open-clip-torch
          ftfy
          onnxruntime
        ]
        ++ [ ps."color-matcher" ];
      torchPkgs = final.lib.optionals (ps ? torch) [ ps.torch ];
      optionals =
        torchPkgs
        ++ final.lib.optionals (ps ? torchvision) [ ps.torchvision ]
        ++ final.lib.optionals (ps ? torchaudio) [ ps.torchaudio ]
        ++ final.lib.optionals (ps ? torchsde) [ ps.torchsde ]
        ++ final.lib.optionals (ps ? pydantic) [ ps.pydantic ]
        ++ final.lib.optionals (ps ? spandrel) [ ps.spandrel ]
        ++ final.lib.optionals (ps ? pyopengl) [ ps.pyopengl ]
        ++ final.lib.optionals (ps ? gitpython) [ ps.gitpython ]
        ++ final.lib.optionals (ps ? toml) [ ps.toml ]
        ++ final.lib.optionals (ps ? rich) [ ps.rich ]
        ++ final.lib.optionals (final.stdenv.isLinux && final.stdenv.isx86_64 && ps ? kornia) [
          ps.kornia
        ]
        ++ final.lib.optionals (ps ? "comfy-cli") [ ps."comfy-cli" ]
        ++ final.lib.optionals (final.stdenv.isLinux && ps ? bitsandbytes) [ ps.bitsandbytes ]
        ++ final.lib.optionals (final.stdenv.isLinux && ps ? xformers) [ ps.xformers ]
        ++ final.lib.optionals (final.stdenv.isLinux && ps ? triton) [ ps.triton ]
        ++ final.lib.optionals (ps ? insightface) [ ps.insightface ]
        ++ final.lib.optionals (ps ? facexlib) [ ps.facexlib ]
        ++ [
          vendoredFixed.comfyuiFrontendPackage
          vendoredFixed.comfyuiWorkflowTemplates
          vendoredFixed.comfyuiEmbeddedDocs
          vendoredFixed.comfyuiManager
          vendoredFixed.comfyKitchen
          vendoredFixed.comfyAimdo
          vendoredFixed.gradioClient
          vendoredFixed.gradio
          vendoredFixed.sageattention
        ]
        ++ final.lib.optionals (vendoredFixed.comfyAngle != null) [ vendoredFixed.comfyAngle ];
    in
    base ++ extras ++ optionals
  );

  frontendRoot = "${pythonRuntimeFixed}/${python.sitePackages}/comfyui_frontend_package/static";

  libPath = final.lib.makeLibraryPath (
    with final;
    [
      stdenv.cc.cc.lib
      glib
      libGL
      libice
      libsm
      libx11
      libxau
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxdmcp
      libxext
      libxfixes
      libxi
      libxkbcommon
      libxrandr
      libxrender
    ]
  );

  comfyUiLauncherFixed = final.writeShellApplication {
    name = "comfy-ui";
    runtimeInputs =
      with final;
      [
        coreutils
        findutils
        gnused
        git
      ]
      ++ final.lib.optionals (!stdenv.isDarwin) [ xdg-utils ];
    text = ''
      ulimit -n 10240 2>/dev/null || true
      BASE_DIR="''${COMFY_USER_DIR:-$HOME/.config/comfy-ui}"
      OPEN_BROWSER=false
      PORT=8188
      COMFY_ARGS=()
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --base-directory=*) BASE_DIR="''${1#*=}"; shift ;;
          --base-directory) BASE_DIR="$2"; shift 2 ;;
          --port=*) PORT="''${1#*=}"; COMFY_ARGS+=("$1"); shift ;;
          --port) PORT="$2"; COMFY_ARGS+=("$1" "$2"); shift 2 ;;
          --open) OPEN_BROWSER=true; shift ;;
          *) COMFY_ARGS+=("$1"); shift ;;
        esac
      done
      BASE_DIR="''${BASE_DIR/#\~/$HOME}"
      mkdir -p "$BASE_DIR"/{models,output,input,user,custom_nodes,temp,web}
      mkdir -p "$BASE_DIR/web/extensions"
      mkdir -p "$BASE_DIR/models"/{checkpoints,loras,vae,controlnet,embeddings,upscale_models,clip,clip_vision,diffusion_models,text_encoders,unet,configs,diffusers,vae_approx,gligen,hypernetworks,photomaker,style_models,classifiers,t2i_adapter,audio_encoders,background_removal,detection,frame_interpolation,geometry_estimation,latent_upscale_models,model_patches,optical_flow}
      export COMFYUI_BASE_DIR="$BASE_DIR"
      if [[ -d "${templateInputs}/input" ]]; then
        for f in "${templateInputs}"/input/*; do
          [[ -e "$f" ]] || continue
          t="$BASE_DIR/input/$(basename "$f")"
          [[ ! -e "$t" ]] && ln -sf "$f" "$t"
        done
      fi
      FONTS_DIR="$BASE_DIR/fonts"
      mkdir -p "$FONTS_DIR"
      for f in "${bundledFonts}"/ttf/*.ttf "${bundledFonts}"/ttf/*.TTF; do
        [[ -e "$f" ]] || continue
        t="$FONTS_DIR/$(basename "$f")"
        [[ ! -e "$t" ]] && ln -sf "$f" "$t"
      done
      COMFYROLL="$BASE_DIR/custom_nodes/ComfyUI_Comfyroll_CustomNodes/nodes/nodes_graphics_text.py"
      [[ -f "$COMFYROLL" ]] && grep -q '"/usr/share/fonts/truetype"' "$COMFYROLL" 2>/dev/null && \
        sed -i "s|\"/usr/share/fonts/truetype\"|\"$FONTS_DIR\"|g" "$COMFYROLL"
      PYSSSSS="$BASE_DIR/custom_nodes/comfyui-custom-scripts/pysssss.py"
      [[ -f "$PYSSSSS" ]] && grep -q 'get_comfy_dir("web/extensions/pysssss")' "$PYSSSSS" 2>/dev/null && \
        sed -i 's|dir = get_comfy_dir("web/extensions/pysssss")|dir = os.path.join(os.environ.get("COMFYUI_BASE_DIR", get_comfy_dir()), "web/extensions/pysssss")|g' "$PYSSSSS"
      for node_dir in model_downloader ComfyUI-Impact-Pack rgthree-comfy ComfyUI-KJNodes ComfyUI-GGUF ComfyUI-LTXVideo ComfyUI-Florence2 ComfyUI_bitsandbytes_NF4 x-flux-comfyui ComfyUI-MMAudio PuLID_ComfyUI ComfyUI-WanVideoWrapper; do
        [[ -e "$BASE_DIR/custom_nodes/$node_dir" && ! -L "$BASE_DIR/custom_nodes/$node_dir" ]] && rm -rf "$BASE_DIR/custom_nodes/$node_dir"
      done
      [[ "$(uname)" == "Darwin" ]] && rm -f "$BASE_DIR/custom_nodes/ComfyUI_bitsandbytes_NF4" 2>/dev/null || true
      find "$BASE_DIR/web/extensions" -maxdepth 1 -type d ! -writable -exec rm -rf {} \; 2>/dev/null || true
      ln -sfn "${modelDownloaderDir}" "$BASE_DIR/custom_nodes/model_downloader"
      ln -sfn "${customNodes.impact-pack}" "$BASE_DIR/custom_nodes/ComfyUI-Impact-Pack"
      ln -sfn "${customNodes.rgthree-comfy}" "$BASE_DIR/custom_nodes/rgthree-comfy"
      ln -sfn "${customNodes.kjnodes}" "$BASE_DIR/custom_nodes/ComfyUI-KJNodes"
      ln -sfn "${customNodes.gguf}" "$BASE_DIR/custom_nodes/ComfyUI-GGUF"
      ln -sfn "${customNodes.ltxvideo}" "$BASE_DIR/custom_nodes/ComfyUI-LTXVideo"
      ln -sfn "${customNodes.florence2}" "$BASE_DIR/custom_nodes/ComfyUI-Florence2"
      [[ "$(uname)" != "Darwin" ]] && ln -sfn "${customNodes.bitsandbytes-nf4}" "$BASE_DIR/custom_nodes/ComfyUI_bitsandbytes_NF4"
      ln -sfn "${customNodes.x-flux}" "$BASE_DIR/custom_nodes/x-flux-comfyui"
      ln -sfn "${customNodes.mmaudio}" "$BASE_DIR/custom_nodes/ComfyUI-MMAudio"
      ln -sfn "${customNodes.pulid}" "$BASE_DIR/custom_nodes/PuLID_ComfyUI"
      ln -sfn "${customNodes.wanvideo}" "$BASE_DIR/custom_nodes/ComfyUI-WanVideoWrapper"
      MC="$BASE_DIR/user/__manager/config.ini"
      if [[ ! -e "$MC" ]]; then
        mkdir -p "$(dirname "$MC")"
        cp "${managerConfig}" "$MC"
      fi
      export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      [[ -d "/run/opengl-driver/lib" ]] && export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
      VENV_DIR="$BASE_DIR/.venv"
      SP="$VENV_DIR/lib/python3.12/site-packages"
      mkdir -p "$SP" "$VENV_DIR/bin"
      if [[ ! -e "$VENV_DIR/pyvenv.cfg" ]]; then
        cat > "$VENV_DIR/pyvenv.cfg" <<PYVENV
home = ${pythonRuntimeFixed}/bin
include-system-site-packages = true
version = 3.12.9
PYVENV
      fi
      if [[ ! -e "$VENV_DIR/bin/python" ]]; then
        ln -sf "${pythonRuntimeFixed}/bin/python" "$VENV_DIR/bin/python"
        ln -sf "${pythonRuntimeFixed}/bin/python3" "$VENV_DIR/bin/python3"
        ln -sf "${pythonRuntimeFixed}/bin/python3.12" "$VENV_DIR/bin/python3.12"
      fi
      export VIRTUAL_ENV="$VENV_DIR" PIP_TARGET="$SP"
      SCD="$BASE_DIR/.comfyui_sitecustomize"
      mkdir -p "$SCD"
      cat > "$SCD/sitecustomize.py" <<'SITEEOF'
import os, site, sys
p = os.environ.get("COMFY_VENV_PRECEDENCE", "")
v = os.environ.get("VIRTUAL_ENV")
if v:
    sp = os.path.join(v, "lib", f"python{sys.version_info.major}.{sys.version_info.minor}", "site-packages")
    if os.path.isdir(sp):
        (sys.path.insert(0, sp) if p == "prefer-venv" else site.addsitedir(sp))
SITEEOF
      export PYTHONPATH="$SCD''${PYTHONPATH:+:$PYTHONPATH}"
      export PIP_CONSTRAINT="${pipConstraints}" UV_CONSTRAINT="${pipConstraints}"
      export COMFYUI_MODEL_PATH="$BASE_DIR/models"
      export TORCH_HOME="$BASE_DIR/.cache/torch" HF_HOME="$BASE_DIR/.cache/huggingface"
      mkdir -p "$TORCH_HOME" "$HF_HOME"
      export FACEXLIB_MODELPATH="$BASE_DIR/.cache/facexlib"
      mkdir -p "$FACEXLIB_MODELPATH/facexlib/weights"
      [[ "$OPEN_BROWSER" == "true" ]] && (sleep 3 && xdg-open "http://127.0.0.1:$PORT" 2>/dev/null) &
      exec "${pythonRuntimeFixed}/bin/python" "${comfyuiSrc}/main.py" \
        --base-directory "$BASE_DIR" \
        --front-end-root "${frontendRoot}" \
        --database-url "sqlite:///$BASE_DIR/user/comfyui.db" \
        "''${COMFY_ARGS[@]}"
    '';
  };

  comfyUiPackageFixed = final.stdenv.mkDerivation {
    pname = "comfy-ui";
    version = versions.comfyui.version;
    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;
    nativeBuildInputs = [ final.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${comfyUiLauncherFixed}/bin/comfy-ui $out/bin/comfy-ui
      ln -s $out/bin/comfy-ui $out/bin/comfyui
    '';
    passthru = {
      inherit comfyuiSrc modelDownloaderDir frontendRoot;
      pythonRuntime = pythonRuntimeFixed;
      version = versions.comfyui.version;
    };
    meta = with final.lib; {
      description = "ComfyUI - A powerful and modular diffusion model GUI";
      homepage = "https://github.com/Comfy-Org/ComfyUI";
      license = with licenses; [
        gpl3
        agpl3Only
        mit
        asl20
      ];
      platforms = platforms.linux ++ platforms.darwin;
      mainProgram = "comfy-ui";
    };
  };
in
{
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (pythonFinal: pythonPrev: {
      "gradio-client" = (pythonPrev."gradio-client" or pythonFinal."gradio-client").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "gradio" = (pythonPrev."gradio" or pythonFinal."gradio").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "comfyui-manager" = (pythonPrev."comfyui-manager" or pythonFinal."comfyui-manager").overridePythonAttrs (_: {
        dontCheckRuntimeDeps = true;
      });
      "inline-snapshot" = (pythonPrev."inline-snapshot" or pythonFinal."inline-snapshot").overridePythonAttrs (_: {
        doCheck = false;
      });
      "mss" = (pythonPrev."mss" or pythonFinal."mss").overridePythonAttrs (_: {
        doCheck = false;
      });
    })
  ];

  comfy-ui-rocm = comfyUiPackageFixed;
}
