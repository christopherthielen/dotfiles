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

**Tip:** `dotfiles` is aliased to `chezmoi`.

---

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Config template (prompts for isWork, email, etc.)
├── .chezmoidata/packages.toml      # Package lists for brew/apt
├── .chezmoiexternal.toml           # External git repos (astronvim)
├── .chezmoiignore                  # Files to skip based on OS/conditions
├── bootstrap.sh                    # Initial bootstrap script
├── dot_zshrc.tmpl                  # ~/.zshrc
├── dot_gitconfig.tmpl              # ~/.gitconfig
├── dot_gitignore_global            # ~/.gitignore_global
├── dot_nvimrc                      # ~/.nvimrc (sources .vimrc)
├── dot_vimrc                       # ~/.vimrc (basic vim settings)
├── dot_config/
│   ├── starship.toml.tmpl          # Starship prompt config
│   ├── (nvim managed via .chezmoiexternal.toml)
│   └── zsh/
│       ├── aliases.zsh.tmpl        # Shell aliases
│       ├── git.zsh                 # Git helper functions
│       └── tools.zsh.tmpl          # Tool integrations (fnm, fzf, mcfly, etc.)
├── dot_dotfiles/
│   └── symlink_personal.tmpl       # Symlink ~/.dotfiles/personal → this repo
├── bin/
│   └── executable_killport         # Kill process on port
└── .chezmoiscripts/
    ├── run_once_before_bootstrap_darwin.sh     # Install Homebrew (macOS)
    ├── run_once_before_bootstrap_linux.sh      # Install apt prereqs + Linuxbrew
    ├── run_onchange_after_install-packages.sh.tmpl  # Install brew/apt packages
    ├── run_onchange_after_install-extras_linux.sh   # Linux extras (tag)
    ├── run_once_after_setup_darwin.sh          # macOS defaults + asimov (once)
    └── run_once_after_setup.sh.tmpl            # git-lfs, nvim plugins (once)
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

#### 3. `run_once_before_` Scripts (Before Files Are Copied)
Scripts run in alphabetical order, filtered by OS guards:

| Script | OS | Purpose |
|--------|-----|---------|
| `run_once_before_bootstrap_darwin.sh` | macOS | Install Homebrew to `/opt/homebrew` or `/usr/local` |
| `run_once_before_bootstrap_linux.sh` | Linux | Install apt prerequisites + Linuxbrew to `/home/linuxbrew/.linuxbrew` |

#### 4. File Application
Chezmoi applies all dotfiles:
- Templates (`.tmpl`) are rendered with your config data
- Encrypted files (`.age`) are decrypted using your age key
- Symlinks are created
- External repos are cloned (`.chezmoiexternal.toml` → AstroNvim config)

#### 5. `run_onchange_` Scripts (When Content Changes)
These run when the script content (or referenced data) changes:

| Script | Purpose |
|--------|---------|
| `run_onchange_after_install-packages.sh.tmpl` | Install brew formulae, casks, apt packages from `packages.toml` |
| `run_onchange_after_install-extras_linux.sh` | Install Linux tools not in package managers (e.g., `tag` via `go install`) |

#### 6. `run_once_after_` Scripts (First Time Only)
These run exactly once per machine (tracked by chezmoi state):

| Script | OS | Purpose |
|--------|-----|---------|
| `run_once_after_setup_darwin.sh` | macOS | macOS defaults (key repeat, etc.) + start asimov |
| `run_once_after_setup.sh.tmpl` | All | Configure git-lfs, initialize neovim plugins |

#### 7. First Shell Launch (`zsh`)
When you start zsh for the first time:
- **zinit** auto-installs (plugin manager)
- OMZ snippets and plugins download
- **fnm** installs the configured Node.js version
- **mcfly** imports shell history

### Script Execution Summary

```
bootstrap.sh
    └── chezmoi init --apply
            ├── .chezmoi.toml.tmpl                    → prompts for config
            ├── run_once_before_bootstrap_*.sh        → install Homebrew
            ├── [apply all dotfiles]                  → templates, symlinks, externals
            ├── run_onchange_after_install-packages.sh.tmpl  → brew/apt packages
            ├── run_onchange_after_install-extras_linux.sh   → Linux extras
            ├── run_once_after_setup_darwin.sh        → macOS defaults, asimov
            └── run_once_after_setup.sh.tmpl          → git-lfs, nvim plugins
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
[".config/nvim"]
    type = "git-repo"
    url = "https://github.com/christopherthielen/astronvim.git"
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

This setup uses `age` encryption for secrets that must remain private even in a public repo.

**File locations:**

```
~/.config/chezmoi/key.txt          # Your private key (NEVER commit this)
~/.local/share/chezmoi/encrypted_*.age  # Encrypted files (safe to commit)
```

**Note:** Work-specific configuration has been moved to a separate internal repo. See [Work Configuration](#work-configuration) below.

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

## Work Configuration

Work-specific dotfiles are managed in a separate internal repository that layers on top of this one. This keeps work-internal references (DNS names, tool configurations) out of the public repo while avoiding unnecessary encryption overhead.

**Architecture:**
- Personal dotfiles work standalone without any work config
- Work config is additive (supplements, never replaces)
- Conditional entry points in personal files include/source work files:
  - `.gitconfig` has `[include] path = ~/.gitconfig_work`
  - `.zshrc` sources `~/.config/zsh/*.zsh` (includes `work.zsh` if present)

**Symlinks (created by chezmoi):**
- `~/.dotfiles/personal` → `~/.local/share/chezmoi`
- `~/.dotfiles/work` → work dotfiles repo (if present)

On work machines, a `chezmoi` wrapper function applies both sources automatically.

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
