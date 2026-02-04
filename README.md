# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/).

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh -o bootstrap.sh && bash bootstrap.sh && zsh
```

This will prompt for your age key, install Homebrew, and apply all dotfiles.

## Daily Usage

| Task | Command |
|------|---------|
| Pull latest + apply | `chezmoi update` |
| Preview changes | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Edit a file | `chezmoi edit ~/.zshrc` |
| Add a new file | `chezmoi add ~/.newfile` |

---

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Config template (prompts for isWork, email, etc.)
├── .chezmoidata/packages.toml      # Package lists for brew/apt
├── .chezmoiexternal.toml           # External git repos (kickstart.nvim)
├── .chezmoiignore                  # Files to skip based on OS/conditions
├── bootstrap.sh                    # Initial bootstrap script
├── dot_zshrc.tmpl                  # ~/.zshrc
├── dot_gitconfig.tmpl              # ~/.gitconfig
├── dot_gitignore_global            # ~/.gitignore_global
├── dot_nvimrc                      # ~/.nvimrc (sources .vimrc)
├── dot_vimrc                       # ~/.vimrc (basic vim settings)
├── dot_config/
│   ├── starship.toml.tmpl          # Starship prompt config
│   ├── symlink_nvim.tmpl           # Symlink ~/.config/nvim → ~/.kickstart.nvim
│   └── zsh/
│       ├── aliases.zsh.tmpl        # Shell aliases
│       ├── git.zsh                 # Git helper functions
│       └── tools.zsh.tmpl          # Tool integrations (fnm, fzf, mcfly, etc.)
├── bin/
│   └── executable_killport         # Kill process on port
├── encrypted_*.age                 # Encrypted work configs and secrets
└── .chezmoiscripts/                # Scripts (don't create target dirs)
    ├── run_before_bootstrap_darwin.sh      # Install Homebrew (macOS)
    ├── run_before_bootstrap_linux.sh       # Install apt prereqs + Linuxbrew
    ├── run_onchange_install-packages.sh.tmpl   # Install brew/apt packages
    ├── run_onchange_after_install-extras_linux.sh  # Linux extras (tag)
    ├── run_once_defaults_darwin.sh         # macOS defaults (once)
    ├── run_once_after_setup.sh.tmpl        # git-lfs, asimov (once)
    └── run_after_update-kickstart.sh       # Sync kickstart (every apply)
```

## Naming Conventions

| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_` | Becomes `.` (dot_zshrc → .zshrc) |
| `executable_` | chmod +x |
| `private_` | chmod 600 |
| `symlink_` | Creates a symlink |
| `encrypted_` | Decrypted on apply (needs age key) |
| `run_before_` | Script runs before files are copied |
| `run_after_` | Script runs after files are copied (every apply) |
| `run_once_` | Script runs once per machine |
| `run_onchange_` | Script runs when its content changes |
| `_darwin` | Only applies on macOS |
| `_linux` | Only applies on Linux |
| `.tmpl` | Template - processed with Go text/template |

## Templating

Templates use Go's `text/template` syntax with access to:

```
{{ .chezmoi.os }}           # "darwin" or "linux"
{{ .chezmoi.arch }}         # "arm64" or "amd64"
{{ .chezmoi.hostname }}     # machine hostname
{{ .isWork }}               # Custom variable from config
{{ .email }}                # Custom variable from config
```

**Example from `dot_gitconfig.tmpl`:**

```
{{- if .isWork -}}
##### BEGIN METATRON AUTOCONFIG
[include]
    path = ~/.gitconfig-proxy
##### END METATRON AUTOCONFIG
{{ end }}

[user]
    name = {{ .name }}
    email = {{ .email }}

{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}

{{- if .isWork }}
[include]
    path = ~/.gitconfig_work
{{- end }}
```

## OS Conditionals

Three ways to handle OS-specific config:

**1. In templates (inline):**

```
{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}
```

**2. In `.chezmoiignore` (skip entire files):**

```
{{- if ne .chezmoi.os "darwin" }}
Library/**
{{- end }}

{{- if not .isWork }}
.config/zsh/work.zsh
{{- end }}
```

**3. Separate files with OS suffix:**

```
run_before_bootstrap_darwin.sh   # macOS only
run_before_bootstrap_linux.sh    # Linux only
run_once_defaults_darwin.sh      # macOS only
```

## Bootstrapping a New Machine

```bash
# One-liner (prompts for age key, installs everything, launches zsh)
curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh -o bootstrap.sh && bash bootstrap.sh && zsh
```

### Order of Operations

The bootstrap process follows this sequence:

#### 1. `bootstrap.sh` (Entry Point)
- Prompts for your **age encryption key** (paste from Bitwarden, Ctrl+D to save)
- Saves key to `~/.config/chezmoi/key.txt`
- Downloads chezmoi binary to `~/.local/bin/chezmoi`
- Runs `chezmoi init --apply christopherthielen/dotfiles`

#### 2. `chezmoi init` Phase
- Clones this repo to `~/.local/share/chezmoi`
- Processes `.chezmoi.toml.tmpl` → prompts for:
  - **Is this a work machine?** (auto-detects based on hostname/metatron)
  - **Email address** (work or personal default)
  - **Full name**
- Saves answers to `~/.config/chezmoi/chezmoi.toml`

#### 3. `run_before_` Scripts (Before Files Are Copied)
Scripts run in alphabetical order, filtered by OS guards:

| Script | OS | Purpose |
|--------|-----|---------|
| `run_before_bootstrap_darwin.sh` | macOS | Install Homebrew to `/opt/homebrew` or `/usr/local` |
| `run_before_bootstrap_linux.sh` | Linux | Install apt prerequisites + Linuxbrew to `/home/linuxbrew/.linuxbrew` |

#### 4. File Application
Chezmoi applies all dotfiles:
- Templates (`.tmpl`) are rendered with your config data
- Encrypted files (`.age`) are decrypted using your age key
- Symlinks are created (e.g., `~/.config/nvim` → `~/.kickstart.nvim`)
- External repos are cloned (`.chezmoiexternal.toml` → kickstart.nvim)

#### 5. `run_onchange_` Scripts (When Content Changes)
These run when the script content (or referenced data) changes:

| Script | Purpose |
|--------|---------|
| `run_onchange_install-packages.sh.tmpl` | Install brew formulae, casks, apt packages from `packages.toml` |
| `run_onchange_after_install-extras_linux.sh` | Install Linux tools not in package managers (e.g., `tag` via `go install`) |

#### 6. `run_once_` Scripts (First Time Only)
These run exactly once per machine (tracked by chezmoi state):

| Script | OS | Purpose |
|--------|-----|---------|
| `run_once_defaults_darwin.sh` | macOS | Set macOS defaults (key repeat, show ~/Library, etc.) |
| `run_once_after_setup.sh.tmpl` | All | Configure git-lfs, start asimov (macOS), initialize neovim plugins |

#### 7. `run_after_` Scripts (Every Apply)
| Script | Purpose |
|--------|---------|
| `run_after_update-kickstart.sh` | Sync kickstart.nvim with upstream changes |

#### 8. First Shell Launch (`zsh`)
When you start zsh for the first time:
- **zinit** auto-installs (plugin manager)
- OMZ snippets and plugins download
- **fnm** installs the configured Node.js version
- **mcfly** imports shell history

### Script Execution Summary

```
bootstrap.sh
    └── chezmoi init --apply
            ├── .chezmoi.toml.tmpl          → prompts for config
            ├── run_before_bootstrap_*.sh   → install Homebrew
            ├── [apply all dotfiles]        → templates, symlinks, externals
            ├── run_onchange_install-packages.sh.tmpl  → brew/apt packages
            ├── run_onchange_after_install-extras_linux.sh  → Linux extras
            ├── run_once_defaults_darwin.sh → macOS defaults
            ├── run_once_after_setup.sh.tmpl → git-lfs, nvim plugins
            └── run_after_update-kickstart.sh → sync kickstart.nvim
zsh (first launch)
    └── zinit, fnm, mcfly initialize
```

### Manual Workflow (After Bootstrap)

```bash
chezmoi update    # Pull latest from git + apply
chezmoi diff      # Preview what would change
chezmoi apply     # Apply changes
chezmoi edit ~/.zshrc  # Edit and auto-apply
```

## Package Management

Packages are defined in `.chezmoidata/packages.toml`:

```toml
[brew.common]
formulae = ["autojump", "bat", "fzf", "neovim", ...]

[darwin.brew]
formulae = ["mas", "coreutils", ...]
casks = ["ghostty", "docker", "raycast", ...]

[darwin.mas]
apps = [{ id = "1352778147", name = "Bitwarden" }, ...]

[linux.apt]
packages = ["build-essential", "zsh", ...]

[linux.brew]
formulae = ["fx", "go", ...]
```

The `run_onchange_install-packages.sh.tmpl` script reads from this data and installs packages. Adding a package to the toml file triggers a re-run on next `chezmoi apply`.

**Key behaviors:**
- `run_before_` - Runs before files are copied (used for Homebrew install)
- `run_once_` - Runs once ever (tracked by filename hash)
- `run_onchange_` - Runs when file content changes (add a package → re-runs)

**To update packages:** Edit `.chezmoidata/packages.toml`, then `chezmoi apply`.

**For ad-hoc updates:** Just run `brew upgrade` directly - chezmoi doesn't fight you.

## External Dependencies

The `.chezmoiexternal.toml` manages git repos and archives:

```toml
[".kickstart.nvim"]
    type = "git-repo"
    url = "https://github.com/christopherthielen/kickstart.nvim.git"
    refreshPeriod = "168h"   # Re-pull weekly
```

These are cloned/updated automatically on `chezmoi apply`.

## Zsh Plugin Management

Zsh plugins are managed by **zinit** (not oh-my-zsh). Zinit auto-installs on first shell launch.

**Key features:**
- Turbo mode: plugins load asynchronously for fast startup
- OMZ compatibility: loads OMZ libraries and plugins as snippets
- Auto-updates: `zinit update` updates all plugins

**Plugins loaded:**
- OMZ libraries: completion, directories, history, key-bindings
- OMZ plugins: git, docker, sudo, node, npm, yarn
- Third-party: zsh-vi-mode, zsh-autosuggestions, zsh-syntax-highlighting

**Tool integrations (in `tools.zsh.tmpl`):**
- fnm (Node version manager)
- fzf (fuzzy finder - Ctrl-T for files, Alt-C for cd)
- mcfly (history search - Ctrl-R)
- starship (prompt)
- autojump (directory jumping - `j <dir>`)
- tag-ag (jump-to-line aliases for ag)

## Secrets Management

This setup uses `age` encryption.

**File locations:**

```
~/.config/chezmoi/key.txt          # Your private key (NEVER commit this)
~/.local/share/chezmoi/encrypted_*.age  # Encrypted files (safe to commit)
```

**Encrypted files in this repo:**
- `encrypted_private_dot_npmrc.age` - npm auth tokens
- `encrypted_dot_gitconfig_work.tmpl.age` - Work git config
- `encrypted_dot_config/zsh/work.zsh.tmpl.age` - Work shell config
- `encrypted_run_once_install-work-tools.sh.tmpl.age` - Work tools installer
- `bin/encrypted_executable_*.age` - Work utility scripts

**How it works:**

1. **Encrypt a secret:**

   ```bash
   chezmoi add --encrypt ~/.npmrc
   # Creates encrypted_dot_npmrc.age in source
   ```

2. **The encrypted file** looks like random bytes - safe to publish:

   ```
   -----BEGIN AGE ENCRYPTED FILE-----
   YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBCbGtqZ2...
   -----END AGE ENCRYPTED FILE-----
   ```

3. **On `chezmoi apply`**, it decrypts using your key and writes `~/.npmrc`

4. **On a new machine**, `bootstrap.sh` prompts for your age key automatically.

**Your age key** (in `~/.config/chezmoi/key.txt`):
- Generated once, reused on all your machines
- Store it securely (Bitwarden, 1Password, etc.)
- **Never commit it to git**

## Publishing to GitHub

**What to commit** (safe):

```
~/.local/share/chezmoi/           # Your entire source state
├── encrypted_*.age               # Encrypted secrets ✓
├── *.tmpl                        # Templates ✓
├── .chezmoi*.toml                # Config templates ✓
└── everything else               # ✓
```

**What NOT to commit:**

```
~/.config/chezmoi/key.txt         # Your age private key ✗
```

**To publish:**

```bash
cd ~/.local/share/chezmoi
git init
git add .
git commit -m "Initial chezmoi dotfiles"
git remote add origin git@github.com:yourusername/dotfiles.git
git push -u origin main
```

The encrypted files are safe because only someone with your `key.txt` can decrypt them.
