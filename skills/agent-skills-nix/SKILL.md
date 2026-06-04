---
name: agent-skills-nix
description: Declarative management of Agent Skills on Nix with flake-pinned sources, discovery, selection, bundling, and Home Manager/devShell integration
version: 1.0.0
homepage: https://github.com/Kyure-A/agent-skills-nix
---

# agent-skills-nix

Declarative management of Agent Skills (directories containing `SKILL.md`) with flake-pinned sources, discovery, selection, bundling, and Home Manager integration.

## Concepts

- **sources**: Named inputs (flake or path) pointing at a skills root (`subdir`). Optional `idPrefix` namespaces discovered skill IDs to avoid collisions across sources.
- **discover**: Recursively scans sources for directories that contain `SKILL.md`, producing a catalog. Skills can be nested (e.g. `ecosystem/c-ecosystem/`) and their IDs use `/` as separator.
- **skills.enable / skills.enableAll / skills.explicit**: Declaratively pick discovered skills, enable-all (global or by source list), and explicitly specified ones; no accidental auto-install unless you opt in.
- **targets**: Agent-specific destinations synced from a store bundle (structure: `link`, `symlink-tree`, `copy-tree`). Targets are opt-in (`enable = false` by default). The `dest` option supports shell variable expansion at runtime (e.g. `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`).

## Two Approaches

agent-skills-nix provides two distinct approaches for managing skills:

1. **Home Manager Module (Global)**: Skills are installed globally via `home-manager` activation. Best for skills you want available everywhere (e.g., nix-best-practices, find-skills).

2. **devShell / devenv (Project-local)**: Skills are installed to project directories when entering a dev shell. Best for project-specific skills.

## Approach 1: Home Manager Module (Global Skills)

### Setup

Add `agent-skills-nix` and skill sources as flake inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agent-skills.url = "github:Kyure-A/agent-skills-nix";

    # Skill sources (non-flake)
    nix-skills = {
      url = "github:0xbigboss/claude-code";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, agent-skills, ... }@inputs: {
    homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        agent-skills.homeManagerModules.default
        ./home.nix
      ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
```

### Configuration in home.nix

```nix
{ inputs, ... }:
{
  programs.agent-skills = {
    enable = true;

    # Define skill sources
    sources.nix-skills = {
      input = "nix-skills";  # References flake input name
      subdir = "skills";     # Subdirectory containing SKILL.md files
    };
    sources.vercel-skills = {
      input = "vercel-skills";
      subdir = "skills";
    };

    # Select specific skills to enable
    skills.enable = [
      "nix-best-practices"
      "find-skills"
    ];

    # Enable targets (where skills are installed)
    targets.opencode.enable = true;
    targets.claude.enable = true;
    # Other targets: agents, codex, copilot, cursor, windsurf, antigravity, gemini
  };
}
```

### Using with NixOS Flake + Home Manager

When using home-manager as a NixOS module, add the agent-skills module to `sharedModules`:

```nix
{
  # In your flake outputs
  nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
    modules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.sharedModules = [
          agent-skills.homeManagerModules.default
        ];
        home-manager.users.myuser = import ./home.nix;
        home-manager.extraSpecialArgs = { inherit inputs; };
      }
    ];
  };
}
```

### Source Options

Each source supports:

```nix
sources.my-source = {
  input = "my-flake-input";  # Flake input name (string)
  # OR
  path = ./local/path;       # Local path (path type)

  subdir = "skills";         # Subdirectory containing skills (default: ".")
  idPrefix = "myorg";        # Prefix for skill IDs to avoid collisions

  filter = {
    maxDepth = 1;            # Max recursion depth (1 = flat only, null = unlimited)
    nameRegex = "^rust-.*";  # Regex to filter discovered skills
  };
};
```

### Skill Selection Options

```nix
skills = {
  # Enable specific skills by ID
  enable = [ "nix-best-practices" "find-skills" ];

  # Enable ALL discovered skills (true = all, or list of source names)
  enableAll = false;
  # enableAll = true;  # All sources
  # enableAll = [ "nix-skills" ];  # Only from specific sources

  # Explicitly specify skills with customization
  explicit = {
    my-custom-skill = {
      from = "nix-skills";           # Source name
      path = "some-skill";           # Path within source
      rename = "custom-name";        # Optional rename
      packages = [ pkgs.jq ];        # Packages to symlink into skill dir
      transform = { original, dependencies }: ''
        # Custom header
        ${dependencies}
        ${original}
      '';
    };
  };
};
```

### Target Options

Targets define where skills are installed. All targets are opt-in (`enable = false` by default).

```nix
targets = {
  # Global targets (install to $HOME)
  opencode.enable = true;    # $HOME/.config/opencode/skills
  claude.enable = true;      # ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills
  agents.enable = true;      # $HOME/.agents/skills
  codex.enable = true;       # ${CODEX_HOME:-$HOME/.codex}/skills
  copilot.enable = true;     # $HOME/.copilot/skills
  cursor.enable = true;      # $HOME/.cursor/skills
  windsurf.enable = true;    # $HOME/.codeium/windsurf/skills
  antigravity.enable = true; # $HOME/.gemini/antigravity/skills
  gemini.enable = true;      # $HOME/.gemini/skills

  # Custom target with options
  my-target = {
    enable = true;
    dest = "$HOME/.my-agent/skills";
    structure = "symlink-tree";  # "link", "symlink-tree", or "copy-tree"
    systems = [ "x86_64-linux" ];  # Limit to specific systems
  };
};
```

### Default Target Paths

| Target | Global path | Local path |
|--------|-------------|------------|
| agents | `$HOME/.agents/skills` | `.agents/skills` |
| codex | `${CODEX_HOME:-$HOME/.codex}/skills` | `.codex/skills` |
| opencode | `$HOME/.config/opencode/skills` | `.opencode/skills` |
| claude | `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills` | `.claude/skills` |
| copilot | `$HOME/.copilot/skills` | `.github/skills` |
| cursor | `$HOME/.cursor/skills` | `.cursor/skills` |
| windsurf | `$HOME/.codeium/windsurf/skills` | `.windsurf/skills` |
| antigravity | `$HOME/.gemini/antigravity/skills` | `.agent/skills` |
| gemini | `$HOME/.gemini/skills` | `.gemini/skills` |

### Structure Types

- **`link`**: Uses `home.file` symlinks. Requires static paths (no shell variables).
- **`symlink-tree`**: Uses `rsync -a --delete` in activation. Preserves symlinks. Supports shell variables in `dest`.
- **`copy-tree`**: Uses `rsync -aL --delete` in activation. Dereferences symlinks. Supports shell variables in `dest`.

### Commands

```bash
# List discovered skills
nix run .#skills-list

# Install skills to global targets
nix run .#skills-install

# Override destinations
AGENT_SKILLS_DESTS="~/tmp/skills1 ~/tmp/skills2" nix run .#skills-install
```

## Approach 2: devShell / devenv (Project-local Skills)

This approach installs skills to the project directory when entering a dev shell. Ideal for project-specific skills that should be version-controlled with the project.

### Basic devShell Setup

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, agent-skills, anthropic-skills, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      agentLib = agent-skills.lib.agent-skills;

      # Define sources
      sources = {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
      };

      # Discover and select skills
      catalog = agentLib.discoverCatalog sources;
      allowlist = agentLib.allowlistFor {
        inherit catalog sources;
        enable = [ "frontend-design" "skill-creator" ];
      };
      selection = agentLib.selectSkills {
        inherit catalog allowlist sources;
        skills = {};
      };

      # Create bundle
      bundle = agentLib.mkBundle { inherit pkgs selection; };

      # Configure local targets (project-relative paths)
      localTargets = {
        claude = agentLib.defaultLocalTargets.claude // { enable = true; };
        opencode = agentLib.defaultLocalTargets.opencode // { enable = true; };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        shellHook = agentLib.mkShellHook {
          inherit pkgs bundle;
          targets = localTargets;
        };
      };
    };
}
```

### Using with direnv

Add `.envrc` to your project root:

```bash
use flake
```

When you `cd` into the project directory, skills are automatically installed to local targets (e.g., `.claude/skills/`, `.opencode/skills/`).

### Manual Installation (without devShell)

For one-time installation without entering a dev shell:

```nix
{
  inputs = {
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, agent-skills, anthropic-skills, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      agentLib = agent-skills.lib.agent-skills;

      sources = {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
      };

      catalog = agentLib.discoverCatalog sources;
      allowlist = agentLib.allowlistFor {
        inherit catalog sources;
        enable = [ "frontend-design" ];
      };
      selection = agentLib.selectSkills {
        inherit catalog allowlist sources;
        skills = {};
      };
      bundle = agentLib.mkBundle { inherit pkgs selection; };

      localTargets = {
        claude = agentLib.defaultLocalTargets.claude // { enable = true; };
      };
    in
    {
      apps.${system}.skills-install-local = {
        type = "app";
        program = "${agentLib.mkLocalInstallScript {
          inherit pkgs bundle;
          targets = localTargets;
        }}/bin/skills-install-local";
      };
    };
}
```

Then run:

```bash
nix run .#skills-install-local
```

### Local Target Paths

Local targets install to the current working directory (or `AGENT_SKILLS_ROOT` if set):

| Target | Local path |
|--------|------------|
| agents | `.agents/skills` |
| codex | `.codex/skills` |
| opencode | `.opencode/skills` |
| claude | `.claude/skills` |
| copilot | `.github/skills` |
| cursor | `.cursor/skills` |
| windsurf | `.windsurf/skills` |
| antigravity | `.agent/skills` |
| gemini | `.gemini/skills` |

### Environment Variables

- `AGENT_SKILLS_ROOT`: Override root directory for local installation (default: current directory)
- `AGENT_SKILLS_LOCAL_DESTS`: Override destination targets
- `AGENT_SKILLS_FORCE`: Set to `1` to overwrite existing non-Nix-managed paths

### devShell with devenv

If using [devenv](https://devenv.sh/), you can integrate agent-skills-nix:

```nix
# devenv.nix
{ pkgs, lib, inputs, ... }:

let
  agentLib = inputs.agent-skills.lib.agent-skills;

  sources = {
    my-skills = {
      path = inputs.my-skills;
      subdir = "skills";
    };
  };

  catalog = agentLib.discoverCatalog sources;
  allowlist = agentLib.allowlistFor {
    inherit catalog sources;
    enable = [ "my-project-skill" ];
  };
  selection = agentLib.selectSkills {
    inherit catalog allowlist sources;
    skills = {};
  };
  bundle = agentLib.mkBundle { inherit pkgs selection; };

  localTargets = {
    claude = agentLib.defaultLocalTargets.claude // { enable = true; };
  };
in
{
  packages = [ pkgs.git ];

  enterShell = agentLib.mkShellHook {
    inherit pkgs bundle;
    targets = localTargets;
  };
}
```

With `devenv.nix`:

```nix
# devenv.flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    my-skills = {
      url = "github:myorg/my-skills";
      flake = false;
    };
  };

  outputs = { nixpkgs, devenv, agent-skills, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ./devenv.nix
        ];
      };
    };
}
```

## Library Functions

For advanced usage, agent-skills-nix exposes library functions:

```nix
let
  agentLib = agent-skills.lib.agent-skills;

  # Discover skills from sources
  catalog = agentLib.discoverCatalog sources;

  # Build allowlist from enable/enableAll options
  allowlist = agentLib.allowlistFor {
    inherit catalog sources;
    enable = [ "skill-1" "skill-2" ];
    enableAll = false;
  };

  # Select skills (allowlist + explicit)
  selection = agentLib.selectSkills {
    inherit catalog allowlist sources;
    skills = {
      custom-skill = { from = "source-name"; path = "skill-path"; };
    };
  };

  # Create store bundle
  bundle = agentLib.mkBundle { inherit pkgs selection; };

  # Create sync script for activation
  syncScript = agentLib.mkSyncScript {
    inherit pkgs bundle;
    targets = syncTargets;
    system = "x86_64-linux";
  };

  # Create local install script
  localInstallScript = agentLib.mkLocalInstallScript {
    inherit pkgs bundle;
    targets = localTargets;
  };

  # Create shell hook for devShell
  shellHook = agentLib.mkShellHook {
    inherit pkgs bundle;
    targets = localTargets;
  };

  # Get default targets
  globalTargets = agentLib.defaultTargets;
  localTargets = agentLib.defaultLocalTargets;
in
{
  # ...
}
```

## Source Filters

Control discovery with filters:

```nix
sources.my-source = {
  input = "my-skills";
  subdir = "skills";

  # Namespace skill IDs to avoid collisions
  idPrefix = "myorg";  # "pdf" becomes "myorg/pdf"

  filter = {
    # Limit recursion depth
    maxDepth = 1;  # 1 = flat only, 2 = one level nesting, null = unlimited

    # Filter by path regex
    nameRegex = "^rust-.*";  # Only skills matching this pattern
  };
};
```

## Skill Customization

Transform SKILL.md content and add package dependencies:

```nix
programs.agent-skills.skills.explicit = {
  my-skill = {
    from = "my-source";
    path = "some-skill";
    packages = [ pkgs.jq pkgs.curl ];  # Symlinked into skill directory
    transform = { original, dependencies }: ''
      # Custom Header

      ${dependencies}

      ${original}

      # See Also
      - https://example.com
    '';
  };
};
```

This generates:

```
my-skill/
├── SKILL.md
├── jq -> /nix/store/xxx-jq/bin/jq
└── curl/ -> /nix/store/xxx-curl/bin/
```

## Safety / Checks

- Disallows skill IDs containing `/..` or leading `/`
- Disallows source `idPrefix` values ending with `/`
- Verifies `SKILL.md` for discovered and explicit skills
- Fails on duplicate IDs across sources
- Preserves symlinks that stay inside a declared source root
- Drops escaping or dangling symlinks
- Rejects `..` traversal in source `subdir` and explicit skill `path` values
- Caps recursion at 100 levels when maxDepth is null

## Common Patterns

### Pattern 1: Multiple sources with same skill names

```nix
sources.openai = {
  input = "openai-skills";
  subdir = "skills";
  idPrefix = "openai";
};

sources.anthropic = {
  input = "anthropic-skills";
  subdir = "skills";
  idPrefix = "anthropic";
};

skills.enable = [ "openai/pdf" "anthropic/pdf" ];
```

### Pattern 2: Child flake for isolated skills catalog

Separate skills configuration into a child flake to keep main flake clean:

```
project/
├── flake.nix           # Main flake (no skill inputs)
├── home.nix
└── skills/
    ├── flake.nix       # Skills catalog flake
    └── home-manager.nix
```

See: https://github.com/Kyure-A/agent-skills-nix/tree/main/examples/quickstart/child

### Pattern 3: Exclude patterns for agent-managed directories

```nix
programs.agent-skills.excludePatterns = [
  ".system"   # Allow agents to manage their own system skills
  ".cache"
];
```

Set to `[]` for full declarative control.

## Links

- Repository: https://github.com/Kyure-A/agent-skills-nix
- Examples: https://github.com/Kyure-A/agent-skills-nix/tree/main/examples
- Issues: https://github.com/Kyure-A/agent-skills-nix/issues
